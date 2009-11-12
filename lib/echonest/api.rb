require 'digest/md5'
require 'httpclient'
require 'json'

module Echonest
  class Api
    BASE_URL = 'http://developer.echonest.com/api/v4/'
    USER_AGENT = '%s/%s' % ['ruby-echonest', ::Echonest::VERSION]

    include TraditionalApiMethods

    class Error < StandardError; end

    attr_reader :user_agent

    def initialize(api_key)
      @api_key = api_key
      @user_agent = HTTPClient.new(:agent_name => USER_AGENT)
    end

    def track
      ApiMethods::Track.new(self)
    end

    def artist(name=nil)
      if name
        ApiMethods::Artist.new_from_name(self, name)
      else
        ApiMethods::Artist.new(self)
      end
    end

    def song
      ApiMethods::Song.new(self)
    end

    def playlist
      ApiMethods::Playlist.new(self)
    end

    def default_params
      {
        :format => 'json',
        :api_key => @api_key
      }
    end

    def build_params(params)
      params = params.
        merge(default_params)
    end

    def build_params_to_list(params)
      result = []
      hash_to_list = lambda{|kv| [kv[0].to_s, kv[1]]}
      params.each do |param|
        if param.instance_of? Array
          param[1].map do |p1|
            result << [param[0].to_s, p1]
          end
        else
          result << hash_to_list.call(params)
        end
      end
      default_params.each do |kv|
        result << hash_to_list.call(kv) unless params.include? kv[0]
      end
      result
    end

    def request(name, method, params, file = nil)
      if file
        query = build_params(params).sort_by do |param|
          param[0].to_s
        end.inject([]) do |m, param|
          m << [URI.encode(param[0].to_s), URI.encode(param[1])].join('=')
        end.join('&')

        uri = URI.join(BASE_URL, name.to_s)
        uri.query = query

        response_body = @user_agent.__send__(
          method.to_s + '_content',
          uri,
          file.read,
          {
            'Content-Type' => 'application/octet-stream'
          })
      else
        response_body = @user_agent.__send__(
          method.to_s + '_content',
          URI.join(BASE_URL, name.to_s),
          build_params_to_list(params))
      end

      response = Response.new(response_body)
      unless response.success?
        raise Error.new(response.status.message)
      end

      response
    rescue HTTPClient::BadResponseError => e
      raise Error.new('%s: %s' % [name, e.message])
    end
  end

  module ApiMethods
    class Base
      def initialize(api)
        @api = api
      end

      def request(*args)
        name, http_method, params = args
        @api.request(name, http_method, params)
      end

      class << self
        def method_with_required_any(category, method_id, http_method, required, required_any, option, proc, block=nil)
          unless block
            block = Proc.new {|response| response.body}
          end
          method = :request
          required ||= %w[api_key]
          define_method(method_id) do |*args|
            name = "#{category.downcase}/#{method_id.to_s}"
            if args.length > 0
              param_required = {}
              required.each do |k|
                k = k.to_sym
                param_required[k] = args[0].delete(k) if args[0][k]
              end
              param_option = args[0]
            end
            params = ApiMethods::Base.validator(required, required_any, option).call(
              :required => param_required,
              :required_any => proc.call(self),
              :option => param_option)
            block.call(send(method, name, http_method, params))
          end
        end

        def method_with_option(id, option, &block)
          unless block
            block = Proc.new {|response| response.body}
          end
          required = %w[]
          required_any = %w[]
          method = :request
          http_method = :get
          define_method(id) do |*args|
            name = "#{self.class.to_s.split('::')[-1].downcase}/#{id.to_s}"
            block.call(send(method, name, http_method, ApiMethods::Base.validator(required, required_any, option).call(
                  :option => args.length > 0 ? args[0] : {})))
            
          end
        end

        def validator(required, required_any, option)
          Proc.new do |args|
            ApiMethods::Base.build_params_with_validation(args, required, required_any, option)
          end
        end

        def build_params_with_validation(args, required, required_any, option)
          options = {}
          # api_key is common parameter.
          required -= %w[api_key]
          required.each do |name|
            name = name.to_sym
            raise ArgumentError.new("%s is required" % name) unless args[:required][name]
            options[name] = args[:required][name]
          end
          if required_any.length > 0
            unless required_any.inject(false){|r,i| r || args[:required_any].include?(i.to_sym)}
              raise ArgumentError.new("%s is required" % required_any.join(' or '))
            end
            key = required_any.find {|name| args[:required_any].include?(name.to_sym)}
            options[key.to_sym] = args[:required_any][key.to_sym] if key
          end
          if args[:option] && !args[:option].empty?
            option.each do |name|
              name = name.to_sym
              options[name] = args[:option][name] if args[:option][name]
            end
          end
          options
        end
      end
    end

    class Track < Base
      def profile(options)
        @api.request('track/profile',
          :get,
          options.merge(:bucket => 'audio_summary'))
      end

      def analyze(options)
        @api.request('track/analyze',
          :post,
          options.merge(:bucket => 'audio_summary'))
      end

      def upload(options)
        options.update(:bucket => 'audio_summary')

        if options.has_key?(:filename)
          filename = options.delete(:filename)
          filetype = filename.to_s.match(/\.(mp3|au|ogg)$/)[1]

          open(filename) do |f|
            @api.request('track/upload',
              :post,
              options.merge(:filetype => filetype),
              f)
          end
        else
          @api.request('track/upload', :post, options)
        end
      end

      def analysis(filename)
        analysis_url = analysis_url(filename)
        Analysis.new_from_url(analysis_url)
      end

      def analysis_url(filename)
        md5 = Digest::MD5.hexdigest(open(filename).read)

        while true
          response = profile(:md5 => md5)

          case response.body.track.status
          when 'unknown'
            upload(:filename => filename)
          when 'pending'
            sleep 60
          when 'complete'
            return response.body.track.audio_summary.analysis_url
          when 'error'
            raise Error.new(response.body.track.status)
          when 'unavailable'
            analyze(:md5 => md5)
          end
        block.call(response)
      rescue Error => e
        if e.message == 'Invalid parameter: unknown MD5 file hash'
          upload(filename)
          sleep 30 # wait for serverside analysis
          get_trackinfo(method, filename, &block)
        elsif e.message =~ /Analysis not ready/i
          puts "Analysis not ready...waiting a minute before retry."
          sleep 60
          get_trackinfo(method, filename, &block)
        else
          raise
        end
      end
    end

    class Artist < Base
      class << self
        def new_from_name(echonest, artist_name)
          instance = new(echonest)
          instance.artist_name = artist_name
          instance
        end

        def method_with_artist_id(method_id, option, &block)
          required_any = %w[id name]
          http_method = :get
          proc = lambda {|s| s.artist_name ? {:name => s.artist_name} : {:id => s.artist_id} }
          method_with_required_any('artist', method_id, http_method, [], required_any, option, proc, block)
        end
      end

      attr_accessor :artist_name, :artist_id

      method_with_artist_id(:audio, %w[format results start])
      method_with_artist_id(:biographies, %w[format results start license])
      method_with_artist_id(:blogs, %w[format results start])
      method_with_artist_id(:familiarity, %w[format results start])
      method_with_artist_id(:hotttnesss, %w[format results start])
      method_with_artist_id(:images, %w[format results start license])
      method_with_artist_id(:news, %w[format results start])
      method_with_artist_id(:profile, %w[format results start bucket])
      method_with_artist_id(:reviews, %w[format results start])
      method_with_option(:search, %w[format results bucket limit name description fuzzy_match max_familiarity min_familiarity max_hotttnesss min_hotttnesss sort])
      method_with_artist_id(:songs, %w[format results bucket limit])
      method_with_artist_id(:similar, %w[format results start bucket max_familiarity min_familiarity max_hotttnesss min_hotttnesss reverse limit])
      method_with_artist_id(:terms, %w[format sort])
      method_with_option(:top_hottt, %w[format results start bucket limit type])
      method_with_option(:top_terms, %w[format results])
      method_with_artist_id(:urls, %w[format])
      method_with_artist_id(:video, %w[format results start])
    end

    class Song < Base
      method_with_option(:search, %w[format title artist combined description artist_id results max_tempo min_tempo max_duration min_duration max_loudness min_loudness max_familiarity min_familiarity max_hotttnesss min_hotttnesss min_longitude max_longitude min_latitude max_latitude mode key bucket sort limitt])
      method_with_required_any('song', :profile, :get, %w[api_key id], [], %w[format bucket limit], lambda{})
      method_with_option(:identify, %w[query code artist title release duration genre bucket])
    end

    class Playlist < Base
      method_with_option(:static, %w[format type artist_pick variety artist_id artist song_id description results max_tempo min_tempo max_duration min_duration max_loudness min_loudness artist_max_familiarity artist_min_familiarity artist_max_hotttnesss artist_min_hotttnesss song_max_hotttnesss song_min_hotttnesss artist_min_longitude aritst_max_longitude artist_min_latitude arist_max_latitude mode key bucket sort limit audio])
      method_with_option(:dynamic, %w[format type artist_pick variety artist_id artist song_id description results max_tempo min_tempo max_duration min_duration max_loudness min_loudness artist_max_familiarity artist_min_familiarity artist_max_hotttnesss artist_min_hotttnesss song_max_hotttnesss song_min_hotttnesss artist_min_longitude aritst_max_longitude artist_min_latitude arist_max_latitude mode key bucket sort limit audio session_id dmca rating chain_xspf])
    end
  end
end

class HTTPClient
  def agent_name
    @session_manager.agent_name
  end
end

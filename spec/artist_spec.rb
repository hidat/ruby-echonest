$:.unshift File.dirname(__FILE__)

require 'spec_helper'
require "echonest"

include SpecHelper

describe Echonest::ApiMethods::Artist do
  before do
    @api = Echonest::Api.new('8TPE3VC60ODJTNTFE')
    @artist = Echonest::ApiMethods::Artist.new(@api)
  end

  def self.describe_bundle_for_artist(method, options=nil)
    describe "#{method}" do
      it "should request to artist/#{method} with name" do
        @api.should_receive(:request).with(
          "artist/#{method}",
          :get,
          :name => 'Weezer').and_return{ Echonest::Response.new('{"hello":"world"}') }

        @artist.artist_name = 'Weezer'
        @artist.send(method)
      end

      it "should request to artist/#{method} with id" do
        @api.should_receive(:request).with(
          "artist/#{method}",
          :get,
          :id => '1234').and_return{ Echonest::Response.new('{"hello":"world"}') }

        @artist.artist_id = '1234'
        @artist.send(method)
      end

      it "should request to artist/#{method} with option" do
        options.each do |opt|
          @api.should_receive(:request).with(
            "artist/#{method}",
            :get,
            opt.merge(:name => 'Weezer')).and_return{ Echonest::Response.new('{"hello":"world"}') }

          @artist.artist_name = 'Weezer'
          @artist.send(method, opt)
        end
      end
    end
  end

  def self.describe_bundle_for_option(method, options=nil)
    describe "#{method}" do
      it "should request to artist/#{method}" do
        @api.should_receive(:request).with(
          "artist/#{method}",
          :get,
          {}).and_return{ Echonest::Response.new('{"hello":"world"}') }

        @artist.send(method)
      end

      it "should request to artist/#{method} with option" do
        options.each do |opt|
          @api.should_receive(:request).with(
            "artist/#{method}",
            :get,
            opt).and_return{ Echonest::Response.new('{"hello":"world"}') }

          @artist.send(method, opt)
        end
      end
    end
  end

  describe_bundle_for_artist('audio', [
    {:format => 'json'},
    {:format => 'json', :results => 100},
    {:format => 'json', :results => 100, :start => 20}
  ])

  describe_bundle_for_artist('biographies', [
    {:format => 'json'},
    {:format => 'json', :results => 100},
    {:format => 'json', :results => 100, :start => 20},

    {:format => 'json', :results => 100, :start => 20, :license => 'echo-source'},
    {:format => 'json', :results => 100, :start => 20, :license => ['echo-source', 'cc-by-nc']}
  ])

  describe_bundle_for_artist('blogs', [
    {:format => 'json'},
    {:format => 'json', :results => 100},
    {:format => 'json', :results => 100, :start => 20}
  ])

  describe_bundle_for_artist('familiarity', [
    {:format => 'json'},
    {:format => 'json', :results => 100},
    {:format => 'json', :results => 100, :start => 20}
  ])

  describe_bundle_for_artist('hotttnesss', [
    {:format => 'json'},
    {:format => 'json', :results => 100},
    {:format => 'json', :results => 100, :start => 20}
  ])

  describe_bundle_for_artist('images', [
    {:format => 'json'},
    {:format => 'json', :results => 100},
    {:format => 'json', :results => 100, :start => 20},
    {:format => 'json', :results => 100, :start => 20, :license => 'echo-source'},
    {:format => 'json', :results => 100, :start => 20, :license => ['echo-source', 'cc-by-nc']}
  ])

  describe_bundle_for_artist('news', [
    {:format => 'json'},
    {:format => 'json', :results => 100},
    {:format => 'json', :results => 100, :start => 20}
  ])

  describe_bundle_for_artist('profile', [
    {:format => 'json'},
    {:format => 'json', :results => 100},
    {:format => 'json', :results => 100, :start => 20},
    {:format => 'json', :results => 100, :start => 20, :bucket => 'audio'},
    {:format => 'json', :results => 100, :start => 20, :bucket => ['audio', 'video']}
  ])

  describe_bundle_for_artist('reviews', [
    {:format => 'json'},
    {:format => 'json', :results => 100},
    {:format => 'json', :results => 100, :start => 20}
  ])

  describe_bundle_for_option('search', [
    {:format => 'json'},
    {:format => 'json', :results => 100},
    {:format => 'json', :results => 100, :bucket => 'audio'},
    {:format => 'json', :results => 100, :bucket => %w[audio biographies blogs id:musicbrainz]}
  ])

  describe_bundle_for_artist('songs', [
    {:format => 'json'},
    {:format => 'json', :results => 100},
    {:format => 'json', :results => 100, :bucket => 'audio'},
    {:format => 'json', :results => 100, :bucket => %w[audio biographies blogs id:musicbrainz]}
  ])

  describe_bundle_for_artist('similar', [
    {:format => 'json'},
    {:format => 'json', :results => 100},
    {:format => 'json', :results => 100, :max_familiarity => 0.9},
    {:format => 'json', :results => 100, :bucket => 'audio'},
    {:format => 'json', :results => 100, :bucket => %w[audio biographies blogs id:musicbrainz]}
  ])

  describe_bundle_for_artist('terms', [
    {:format => 'json'},
    {:format => 'json', :sort => 'weight'}
  ])

  describe_bundle_for_option('top_hottt', [
    {:format => 'json'},
    {:format => 'json', :results => 100},
    {:format => 'json', :results => 100, :type => 'normal'},
    {:format => 'json', :results => 100, :bucket => 'audio'},
    {:format => 'json', :results => 100, :bucket => %w[audio biographies blogs id:musicbrainz]}
  ])

  describe_bundle_for_option('top_terms', [
    {:format => 'json'},
    {:format => 'json', :results => 100}
  ])

  describe_bundle_for_option('list_terms', [
    {:format => 'json'},
    {:format => 'json', :type=>:style},
    {:format => 'json', :type=>:mood},
    {:format => 'json', :results => 100}
  ])

  describe_bundle_for_artist('urls', [
    {:format => 'json'}
  ])

  describe_bundle_for_artist('video', [
    {:format => 'json'},
    {:format => 'json', :results => 100},
    {:format => 'json', :results => 100, :start => 20}
  ])
end

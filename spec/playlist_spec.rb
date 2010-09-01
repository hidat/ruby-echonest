$:.unshift File.dirname(__FILE__)

require 'spec_helper'
require "echonest"

include SpecHelper

describe Echonest::ApiMethods::Playlist do
  before do
    @api = Echonest::Api.new('8TPE3VC60ODJTNTFE')
    @song = Echonest::ApiMethods::Playlist.new(@api)
  end

  def self.describe_bundle_for_option(method, options=nil)
    describe "#{method}" do
      it "should request to playlist/#{method}" do
        @api.should_receive(:request).with(
          "playlist/#{method}",
          :get,
          {}).and_return{ Echonest::Response.new('{"hello":"world"}') }

        @song.send(method)
      end

      it "should request to playlist/#{method} with option" do
        options.each do |opt|
          @api.should_receive(:request).with(
            "playlist/#{method}",
            :get,
            opt).and_return{ Echonest::Response.new('{"hello":"world"}') }

          @song.send(method, opt)
        end
      end
    end
  end

  describe_bundle_for_option('static', [
    {:format => 'json'},
    {:format => 'json', :type => 'artist'},
    {:format => 'json', :type => 'artist', :artist_pick => 'loudness'},
    {:format => 'json', :type => 'artist', :artist => 'Weezer'},
    {:format => 'json', :type => 'artist', :artist => ['Weezer', 'the beatles']}
  ])

  describe_bundle_for_option('dynamic', [
    {:format => 'json'},
    {:format => 'json', :type => 'artist'},
    {:format => 'json', :type => 'artist', :artist_pick => 'loudness'},
    {:format => 'json', :type => 'artist', :artist => 'Weezer'},
    {:format => 'json', :type => 'artist', :artist => ['Weezer', 'the beatles']},
    {:session_id => 'foobarbaz'},
    {:session_id => 'foobarbaz', :dmca => 'false'},
    {:session_id => 'foobarbaz', :dmca => 'true', :rating => 3},
  ])
end

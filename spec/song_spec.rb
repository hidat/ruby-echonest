$:.unshift File.dirname(__FILE__)

require 'spec_helper'
require "echonest"

include SpecHelper

describe Echonest::ApiMethods::Song do
  before do
    @api = Echonest::Api.new('8TPE3VC60ODJTNTFE')
    @song = Echonest::ApiMethods::Song.new(@api)
  end

  def self.describe_bundle_for_song(method, options=nil)
    describe "#{method}" do
      it "should request to song/#{method} with id" do
        @api.should_receive(:request).with(
          "song/#{method}",
          :get,
          :id => 'abcd').and_return{ Echonest::Response.new('{"hello":"world"}') }

        @song.send(method, :id => 'abcd')
      end

      it "should request to song/#{method} with option" do
        options.each do |opt|
          @api.should_receive(:request).with(
            "song/#{method}",
            :get,
            opt.merge(:id => 'abcd')).and_return{ Echonest::Response.new('{"hello":"world"}') }

          @song.send(method, opt.merge(:id => 'abcd'))
        end
      end
    end
  end

  def self.describe_bundle_for_option(method, options=nil)
    describe "#{method}" do
      it "should request to song/#{method}" do
        @api.should_receive(:request).with(
          "song/#{method}",
          :get,
          {}).and_return{ Echonest::Response.new('{"hello":"world"}') }

        @song.send(method)
      end

      it "should request to song/#{method} with option" do
        options.each do |opt|
          @api.should_receive(:request).with(
            "song/#{method}",
            :get,
            opt).and_return{ Echonest::Response.new('{"hello":"world"}') }

          @song.send(method, opt)
        end
      end
    end
  end

  describe_bundle_for_option('search', [
    {:format => 'json'},
    {:format => 'json', :title => 'foo'},
    {:format => 'json', :title => 'foo', :sort => 'tempo-asc'},
    {:format => 'json', :results => 100, :bucket => 'audio_summary'},
    {:format => 'json', :results => 100, :bucket => %w[audio_summary tracks song_hotttnesss]}
  ])

  describe_bundle_for_song('profile', [
    {:format => 'json'},
    {:format => 'json', :bucket => 'audio_summary'},
    {:format => 'json', :bucket => 'audio_summary', :limit => 'true'},
    {:format => 'json', :bucket => %w[audio_summary tracks song_hotttnesss]}
  ])

  # describe_bundle_for_option('identify', [
    # {:code => '1234'},
    # {:code => '1234', :genre => 'pop'},
    # {:code => '1234', :genre => 'pop', :bucket => 'audio_summary'},
    # {:code => '1234', :genre => 'pop', :bucket => %w[audio_summary tracks song_hotttnesss]}
  # ])

  describe "identify" do
    it "should request to song/identify with option" do
      @api.should_receive(:request).with("song/identify", :post, {}, nil).and_return{ Echonest::Response.new('{"hello":"world"}') }
      @song.identify({})
    end

  end
end

$:.unshift File.dirname(__FILE__)

require 'spec_helper'
require "echonest"

include SpecHelper

describe Echonest::ApiMethods::Base do
  before do
    @api = Echonest::Api.new('8TPE3VC60ODJTNTFE')
    @base = Echonest::ApiMethods::Base.new(@api)
  end

  it "should call @api.request" do
    @api.should_receive(:request).with(:get, 'method_foo', {:hash => 'paramerter'})
    @base.request(:get, 'method_foo', {:hash => 'paramerter'})
  end

  describe ".build_params_with_validation" do
    it "should pass validation for required key" do
      args = {
        :required => {
          :key1 => 'value1',
        },
      }
      Echonest::ApiMethods::Base.build_params_with_validation(
        args,
        %w[key1],
        [],
        []).should == {:key1 => 'value1'}
    end

    it "should raise error if required key not exist in parametor" do
      lambda {
        args = {
          :required => {
            :key2 => 'value2',
          },
        }
        Echonest::ApiMethods::Base.build_params_with_validation(
          args,
          %w[key1],
          [],
          [])
      }.should raise_error(ArgumentError, 'key1 is required')
    end

    it "should pass validation for required_any key" do
      args = {
        :required_any => {
          :key1 => 'value1',
        },
      }
      Echonest::ApiMethods::Base.build_params_with_validation(
        args,
        [],
        %w[key1 key2],
        []).should == {:key1 => 'value1'}

      args = {
        :required_any => {
          :key2 => 'value2',
        },
      }
      Echonest::ApiMethods::Base.build_params_with_validation(
        args,
        [],
        %w[key1 key2],
        []).should == {:key2 => 'value2'}
    end

    it "should raise error if required_any key not exist in parametor" do
      lambda {
        args = {
          :required_any => {
            :key3 => 'value3',
          },
        }
        Echonest::ApiMethods::Base.build_params_with_validation(
          args,
          [],
          %w[key1 key2],
          [])
      }.should raise_error(ArgumentError, 'key1 or key2 is required')
    end

    it "should pass validation for option key" do
      args = {
        :option => {
          :key1 => 'value1',
        },
      }
      Echonest::ApiMethods::Base.build_params_with_validation(
        args,
        [],
        [],
        %w[key1 key2]).should == {:key1 => 'value1'}
    end

    it "should empty hash for option if keys for option not exist in parametor" do
      args = {
        :option => {
          :key3 => 'value3',
        },
      }
      Echonest::ApiMethods::Base.build_params_with_validation(
        args,
        [],
        [],
        %w[key1 key2]).should == {}
    end

    it "should pass validation for required, required_any and option keys" do
      args = {
        :required => {
          :key1 => 'value1',
        },
        :required_any => {
          :key3 => 'value3',
        },
        :option => {
          :key4 => 'value4',
          :key5 => 'value5',
        },
      }
      Echonest::ApiMethods::Base.build_params_with_validation(
        args, 
        %w[key1],
        %w[key2 key3],
        %w[key4 key5 key6]).should == {
        :key1 => 'value1',
        :key3 => 'value3',
        :key4 => 'value4',
        :key5 => 'value5',
      }
    end
  end

  describe ".validator" do
    it "should return Proc instance" do
      Echonest::ApiMethods::Base.validator(%w[required], %w[required_any], %w[option]).should be_an_instance_of(Proc)
    end
  end

  describe ".method_with_option" do
    before do
      class FooBar < Echonest::ApiMethods::Base
      end
      @foobar = FooBar.new('dummy')
    end

    it "should define_method with option parametor" do
      @foobar.class.class_eval do
        def request(p1, p2, p3)
          p1.should == 'foobar/baz'
          p2.should == :get
          p3.should == {:k1 => 'v1'}
          'test response'
        end

        method_with_option('baz', %w[k1 k2]) do |response|
          response.should == 'test response'
        end
      end

      @foobar.baz(:k1 => 'v1')
    end
  end

  describe ".method_with_required_any" do
    before do
      class FooBar < Echonest::ApiMethods::Base
      end
      @foobar = FooBar.new('dummy')
    end

    it "should define_method with option parametor" do
      @foobar.class.class_eval do
        def request(p1, p2, p3)
          p1.should == 'category/baz'
          p2.should == :get
          p3.should == {
            :rk1 => 'rv1',
            :rak1 => 'ravv1',
            :ok1 => 'ov1'
          }
          'test response'
        end

        method_with_required_any(
          'Category',
          'baz',
          :get,
          %w[rk1],
          %w[rak1 rak2],
          %w[ok1 ok2],
          lambda{|s| {:rak1 => 'ravv1'}},
          lambda{|response| response.should == 'test response'})
      end

      @foobar.baz(
        :rk1 => 'rv1',
        :ok1 => 'ov1')
    end
  end

end

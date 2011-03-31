$:.unshift File.dirname(__FILE__)

require 'spec_helper'
require "echonest"

include SpecHelper

describe Echonest::ApiMethods::Catalog do
  before do
    @api = Echonest::Api.new('8TPE3VC60ODJTNTFE')
    @catalog = Echonest::ApiMethods::Catalog.new(@api)
  end

  describe "#create" do
    it "should request to catalog/create with option" do
      catalog_name = "catalog_name"
      catalog_type = "artist"
      @api.should_receive(:request).with("catalog/create", :post, {:name => catalog_name, :type => catalog_type, :format => "json"}).and_return{ Echonest::Response.new('{"hello":"world"}') }
      @catalog.create(catalog_name, catalog_type)
    end
  end

  describe "#update" do
    it "should request to catalog/update with option" do
      catalog_id = "catalog_id"
      json_data = [{:item=>{:item_id => "hogehoge", :artist_name => "Oscar Peterson"}}].to_json
      @api.should_receive(:request).with("catalog/update", :post, {:id => catalog_id, :data_type => "json", :format => "json", :data => json_data}).and_return{ Echonest::Response.new('{"hello":"world"}') }
      @catalog.update(catalog_id, json_data)
    end
  end
  
end

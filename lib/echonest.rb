require 'echonest/version'
require 'echonest/traditional_api_methods'
require 'echonest/api'
require 'echonest/analysis'
require 'echonest/response'
require 'echonest/element/section'
require 'echonest/element/bar'
require 'echonest/element/beat'
require 'echonest/element/segment'
require 'echonest/element/loudness'
require 'echonest/element/tatum'

def Echonest(api_key) Echonest::Api.new(api_key) end

module Echonest
  extend self

  def debug(obj)
    return unless debug?

    if obj.is_a?(String)
      puts obj
    else
      puts obj.inspect
    end
  end

  # MOAR DEBUGGING! *just for now
  def debug?
    true || ENV['DEBUG']
  end
end

require 'sequel'

DB = Sequel.connect('sqlite://tracks.db')
# DB.drop_table :tracks
# DB.create_table :tracks do
#   primary_key :id
#   String :md5, :length => 32
#   String :filename
#   String :artist, :length => 100
#   String :album
#   String :title
#   Float :duration
#   Float :loudness
#   Float :fade_out
#   Float :fade_in
#   Float :tempo
#   Integer :time_signature, :length => 1
#   Integer :key, :length => 2
#   Integer :mode, :length => 1
#   DateTime :created_on
#   DateTime :updated_on
# end
require 'echonest/version'
require 'echonest/traditional_api_methods'
require 'echonest/api'
require 'echonest/analysis'
require 'echonest/response'
require 'echonest/element/section'
require 'echonest/track'
require 'echonest/playlist'
require 'echonest/element/value_with_confidence'
require 'echonest/element/bar'
require 'echonest/element/beat'
require 'echonest/element/segment'
require 'echonest/element/loudness'
require 'echonest/element/tatum'

def Echonest(api_key) Echonest::Api.new(api_key) end

module Echonest
end

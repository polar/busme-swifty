require 'rubygems'
require 'bundler'
require 'logger'
require 'uri'
require 'mongo'
require 'mongo_mapper'
require 'optparse'
require "rush"
require "require_all"


# This exists for local development. This file does not exist in production..
require  File.expand_path('../aa_creds.rb', File.dirname(__FILE__)) if File.exists?(File.expand_path('../aa_creds.rb', File.dirname(__FILE__)))

require 'net/http'
require "swiftcore/Swiftiply"

begin
  #puts "Loading DB"
  if ENV['MONGOLAB_URI']
    # We are on Heroku and using MONGOLAB for a MongoDB
    uri = URI.parse(ENV['MONGOLAB_URI'])
    MongoMapper.connection = conn = Mongo::Connection.from_uri(ENV['MONGOLAB_URI'])
    MongoMapper.database = (uri.path.gsub(/^\//, ''))
  else
    # Local Configuration for development/testing
    puts "Using a local Mongo DB! Check your ENV"
    MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
    MongoMapper.database = "#Busme-development"
  end
  MongoMapper::Plugins::IdentityMap.enabled = true
  #puts "Connected to DB #{MongoMapper.database.name}"
rescue Exception => boom
  puts "Cannot establish connection to DB #{boom}"
  exit 1
end

dir = File.expand_path("../app/models", File.dirname(__FILE__))
$DEBUG=true
autoload_all File.join(dir, "*.rb"), :base_dir => dir
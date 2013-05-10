puts "Starting Port #{ENV["PORT"]}"

require 'rubygems'
require 'bundler'

require "./aa_creds" if File.exists?("./aa_creds")

puts "Loading Compoents"
require 'logger'

require 'uri'
require 'mongo'
require 'mongo_mapper'

class MyLog
  include MongoMapper::Document
  key :log, Array, :default => []
  def add(s)
    self.push(:log => s)
  end
end


require 'net/http'

require "swiftcore/Swiftiply"
puts "Loading DB"

if ENV['MONGOLAB_URI']

  # We are on Heroku and using MONGOLAB for a MongoDB

  uri = URI.parse(ENV['MONGOLAB_URI'])
  puts "Connected to #{ENV["MONGOLAB_URI"]}"

  MongoMapper.connection = conn = Mongo::Connection.from_uri(ENV['MONGOLAB_URI'])
  MongoMapper.database = (uri.path.gsub(/^\//, ''))

else

  # Local Configuration

  MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
  MongoMapper.database = "#Busme-development"

end
logger = MyLog.new

logger.add("Loaded DB")

puts "Loading Models"
logger.add("Loading Models")
require "./app/models/backend"

Ccluster_address = 'cluster_address'.freeze
Ccluster_port    = 'cluster_port'.freeze
Cconfig_file     = 'config_file'.freeze
Cbackend_address = 'backend_address'.freeze
Cbackend_port    = 'backend_port'.freeze
Cmap             = 'map'.freeze
Cincoming        = 'incoming'.freeze
Coutgoing        = 'outgoing'.freeze
Ckeepalive       = 'keepalive'.freeze
Cdaemonize       = 'daemonize'.freeze
Curl             = 'url'.freeze
Chost            = 'host'.freeze
Cport            = 'port'.freeze
Ctimeout         = 'timeout'.freeze
Cdefault         = 'default'.freeze
Ckey             = 'key'.freeze


def stop_proxy
  puts "Stopping"
  @proxy.destroy if @proxy
end

trap("HUP") { stop_proxy }
trap("INT") { stop_proxy }
trap("TERM") { stop_proxy }

backendport = 12345

config = {}
config[Ccluster_address] = "0.0.0.0"
config[Ccluster_port] = ENV["PORT"].to_i
config[Cmap] = [{}]
config[Cmap][0][Cincoming] = [""]
config[Cmap][0][Coutgoing] = ["0.0.0.0:#{backendport}"]
config[Cmap][0][Ckeepalive] = true
config[Cmap][0][Cdefault] = true
config[Cmap][0][Ckey] = ENV["SWIFT_KEY"]

logger.add "#{config.inspect}"
logger.add "Getting  IP"

slug = ENV["MASTER_SLUG"] || "all"
hostip = Net::HTTP.get(URI.parse('http://ipecho.net/plain'))

logger.add "HOST IP #{hostip}"
@proxy = Backend.new(:master_slug => slug, :host => hostip, :port => backendport)
@proxy.save

logger.add "About to Run Swift"

Swiftcore::Swiftiply.run(config)

logger.add "Exiting"

@proxy.destroy if @proxy
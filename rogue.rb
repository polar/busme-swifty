puts "Starting Port #{ENV["PORT"]}"

require 'rubygems'
require 'bundler'

require "./aa_creds" if File.exists?("./aa_creds.rb")

puts "Loading Compoents"
require 'logger'

require 'uri'
require 'mongo'
require 'mongo_mapper'

class MyLog
  include MongoMapper::Document
  key :log, Array, :default => []
  def add(s)
    self.log << s
    self.save
  end
end

p ENV

require 'net/http'

require "swiftcore/Swiftiply"
puts "Loading DB"

if ENV['MONGOLAB_URI']

  # We are on Heroku and using MONGOLAB for a MongoDB

  uri = URI.parse(ENV['MONGOLAB_URI'])
  puts "Connected to #{ENV["MONGOLAB_URI"]}"
p ENV
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
puts "Done Loading Models"
logger.add("Done Loading Models")

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
Clogger = 'logger'.freeze

Ctype = 'type'.freeze
Clevel = 'level'.freeze


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
config[Clogger] = { Ctype => "stderror", Clevel => 3}
config[Cmap] = [{}]
config[Cmap][0][Cincoming] = [""]
config[Cmap][0][Coutgoing] = ["0.0.0.0:#{backendport}"]
config[Cmap][0][Ckeepalive] = true
config[Cmap][0][Cdefault] = true
config[Cmap][0][Ckey] = ENV["SWIFT_KEY"]

puts "Eatme 1"

logger.add "#{config.inspect}"
logger.add "Getting  IP"

puts "GEtting IP"
      p ENV

slug = ENV["MASTER_SLUG"] || "all"
begin
  hostip = Net::HTTP.get(URI.parse('http://myexternalip.com/raw'))
rescue Exception => boom1
  puts "No IP"
  logger.add "No IP"
  exit 1
end

if hostip.nil?
  puts "NO IP"
  exit 1
end


puts  "HOST IP #{hostip}"
logger.add "HOST IP #{hostip}"
@proxy = Backend.new(:master_slug => slug, :host => hostip, :port => backendport)
@proxy.save

puts "About to Run Swift"
logger.add "About to Run Swift"

p ENV
begin
  puts "#{ENV.inspect}"
  logger.add "Int to Run Swift"
  Swiftcore::Swiftiply.run(config)
  logger.add "Out Swift"
rescue Exception => boom
  puts "#{boom}"
  logger.add "#{boom}"
end

puts "Exiting"
logger.add "Exiting"
puts

@proxy.destroy if @proxy
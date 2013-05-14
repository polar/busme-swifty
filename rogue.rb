puts "Starting Port #{ENV["VCAP_APP_PORT"]}"

require 'rubygems'
require 'bundler'

require "./aa_creds" if File.exists?("./aa_creds.rb")

puts "Loading Components"
require 'logger'

require 'uri'
require 'mongo'
require 'mongo_mapper'

logger = nil

class MyLog
  include MongoMapper::Document
  key :log, Array, :default => []
  def add(s)
    p s
    self.log << s.to_s
    self.save
  end
end

require 'net/http'

require "swiftcore/Swiftiply"
p "Loading DB"

if ENV['MONGOLAB_URI']

  # We are on Heroku and using MONGOLAB for a MongoDB

  uri = URI.parse(ENV['MONGOLAB_URI'])
  p "Connected to #{ENV["MONGOLAB_URI"]}"
  MongoMapper.connection = conn = Mongo::Connection.from_uri(ENV['MONGOLAB_URI'])
  MongoMapper.database = (uri.path.gsub(/^\//, ''))

else

  # Local Configuration

  MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
  MongoMapper.database = "#Busme-development"

end
logger = MyLog.new


logger.add "Connected to #{ENV["MONGOLAB_URI"]}"
logger.add("Loading Models")
require "./app/models/backend"
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
  logger.add "Stopping" if @logger
  @proxy.destroy if @proxy
end

trap("HUP") { stop_proxy }
trap("INT") { stop_proxy }
trap("TERM") { stop_proxy }

backendport = 8081  

port = ENV["VCAP_APP_PORT"] || "8080"
config = {}
config['cluster_address'] = "127.0.0.1"
config['daemonize'] = false
config['cluster_port'] = port.to_i
config['logger'] = { 'type' => "stderror", 'level' => 3}
config['map'] = [{}]
config['map'][0]['incoming'] = ["#{config['cluster_address']}:#{port}"]
config['map'][0]['outgoing'] = ["0.0.0.0:#{backendport}"]
config['map'][0]['keepalive'] = true
config['map'][0]['default'] = true
config['map'][0]['key'] = ENV["SWIFT_KEY"]

logger.add "#{config.inspect}"
logger.add "Getting  IP"

slug = ENV["MASTER_SLUG"]
slug = nil if slug.blank?
begin
  hostip = Net::HTTP.get(URI.parse('http://myexternalip.com/raw'))
rescue Exception => boom1
  logger.add "No IP"
  exit 1
end

if hostip.nil?
  logger.add "NO IP"
  exit 1
end

logger.add "HOST IP #{hostip}"
@proxy = Backend.new(:master_slug => slug, :host => hostip, :port => backendport)
@proxy.save
logger.add "About to Run Swift"
begin
  logger.add "Int to Run Swift"
  Swiftcore::Swiftiply.run(config)
  #sleep 234234234234234
  logger.add "Out Swift"
rescue Exception => boom
 logger.add "#{boom}"
 logger.add boom.backtrace
end

logger.add "Exiting"

@proxy.destroy if @proxy


require 'rubygems'
require 'bundler'
require 'logger'
require 'uri'
require 'mongo'
require 'mongo_mapper'
require 'optparse'


# This exists for local testing.
require "./aa_creds" if File.exists?("./aa_creds.rb")

logger = Logger.new(STDOUT)

require 'net/http'
require "swiftcore/Swiftiply"

logger.info "Busme! Swifty Starting"

logger.info "Loading DB"

begin
  if ENV['MONGOLAB_URI']

    # We are on Heroku and using MONGOLAB for a MongoDB

    uri = URI.parse(ENV['MONGOLAB_URI'])
    MongoMapper.connection = conn = Mongo::Connection.from_uri(ENV['MONGOLAB_URI'])
    MongoMapper.database = (uri.path.gsub(/^\//, ''))

  else

    # Local Configuration for development/testing

    MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
    MongoMapper.database = "#Busme-development"

  end
rescue Exception => boom
  logger.error "Cannot establish connection to DB #{boom}"
  exit 1
end

logger.info "Connected to DB #{MongoMapper.database}"

require "./app/models/backend"

def stop_proxy(signal)
  logger.info "Stopping due to Signal #{signal}" if @logger
  logger.info "Destroying #{@proxy} #{@proxy.inspect}" if @logger
  @proxy.destroy if @proxy
end

# Swiftiply catches these signals. However, these are here
# if we receive them before we start Swiftiply.
trap("HUP") { stop_proxy("HUP") }
trap("INT") { stop_proxy("INT") }
trap("TERM") { stop_proxy("TERM") }

backendport = ENV["SWIFTIPLY_BACKEND_PORT"] || "8081"

port = ENV["SWIFTIPLY_CLUSTER_PORT"] || "3000"
config = {}
config['cluster_address'] = "127.0.0.1"
config['daemonize'] = false
config['cluster_port'] = port.to_i
config['logger'] = { 'type' => "stderror", 'level' => 3}
config['backend_address'] = "0.0.0.0"
config['backend_port'] = "#{backendport}"

##
# Overrides


OptionParser.new do |opts|
  opts.banner = 'Usage: rogue.rb [options]'
  opts.separator ''
  opts.on('-m', '--master-slug [SLUG]', String, 'The Master that this Swifty is serving') do |slug|
    ENV["MASTER_SLUG"] = slug
  end
  opts.on('-a', '--cluster-address [ADDRESS]', String, 'The hostname/IP address that Busme! Swifty will listen for connections on.') do |address|
    config['cluster_address'] = address
  end
  opts.on('-p', '--cluster-port [PORT]', Integer, 'The port that Busme! Swifty will listen for connections on.') do |port|
    config['cluster_port'] = port
  end
  opts.on('--backend-address [ADDRESS]', String, 'The hostname/IP address that Busme! Swifty will listen for backend connections on.') do |address|
    config['backend_address'] = address
  end
  opts.on('--backend-port [PORT]', Integer, 'The port that Busme! Swifty will listen for backend connections on.') do |port|
    config['backend_port'] = port
  end
  opts.on('-t', '--timeout [SECONDS]', Integer, 'The server unavailable timeout.  Defaults to 3 seconds.') do |timeout|
    config['timeout'] = timeout
  end

end.parse!

# Finish Up.

config['map']                 = [{}]
config['map'][0]['incoming']  = ["#{config['cluster_address']}:#{config['cluster_port']}"]
config['map'][0]['outgoing']  = ["#{config['backend_address']}:#{config['backend_port']}"]
config['map'][0]['keepalive'] = true
config['map'][0]['default']   = true
config['map'][0]['key']       = ENV["SWIFTIPLY_KEY"]

logger.info "#{config.inspect}"
logger.info "Getting  IP"

slug = ENV["MASTER_SLUG"]
slug = nil if slug.blank?

logger.info "Running for Master #{slug}" if slug

begin
  hostip = Net::HTTP.get(URI.parse('http://myexternalip.com/raw'))
rescue Exception => boom1
  logger.error "Cannot establish external IP: #{boom1}"
  exit 1
end

if hostip.nil?
  logger.error "Cannot establish external IP"
  exit 1
end

logger.info "External Host IP: #{hostip}"

@proxy = Backend.new(:master_slug => slug, :host => hostip, :port => config['backend_port'])
@proxy.save
logger.info "Saved #{@proxy} #{@proxy.inspect}"
logger.info "Running Swift"

begin
  Swiftcore::Swiftiply.run(config)
  #sleep 234234234234234
  logger.info "Swift Ended Normally, perhaps with a signal."
rescue Exception => boom
 logger.error "Swift Ended Abnormally: #{boom}"
 logger.error boom.backtrace
end

logger.info "Busme! Swifty Exiting"

logger.info "Destroying #{@proxy} #{@proxy.inspect}"
@proxy.destroy if @proxy
logger.info "Done."

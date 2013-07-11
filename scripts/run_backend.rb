#!/usr/bin/env ruby
require "../config/initialize"

require 'net/http'
require "swiftcore/Swiftiply"

frontend_name = nil
backend_name = nil
OptionParser.new do |opts|
  opts.banner = 'Usage: run_backend.rb [options]'
  opts.separator ''
  opts.on('--backend-name [NAME]', String, 'The name of this backend. It must be configured.') do |slug|
    backend_name = slug
  end
end.parse!


backend = Backend.where(:backend_name => backend_name).first

if backend.nil?
  logger.error "Backend #{backend_name} does not exist."
  exit 1
end

def stop_proxy(signal)
  logger.info "Stopping due to Signal #{signal}" if @logger
end

# Swiftiply catches these signals. However, these are here
# if we receive them before we start Swiftiply.
trap("HUP") { stop_proxy("HUP") }
trap("INT") { stop_proxy("INT") }
trap("TERM") { stop_proxy("TERM") }

config = {}
config['daemonize'] = false
config['logger'] = { 'type' => "stderror", 'level' => 3}
config['cluster_address']     = backend.cluster_address
config['cluster_port']        = "#{backend.cluster_port}"
config['backend_address']     = backend.address
config['backend_port']        = "#{backend.port}"
config['timeout']             = backend.timeout
config['map']                 = [{}]
config['map'][0]['incoming']  = ["#{backend.cluster_address}:#{backend.cluster_port}"]
config['map'][0]['outgoing']  = ["#{backend.address}:#{backend.port}"]
config['map'][0]['keepalive'] = true
config['map'][0]['default']   = true
config['map'][0]['key']       = ENV["SWIFTIPLY_KEY"]


begin
  Swiftcore::Swiftiply.run(config)
  logger.info "Swift Ended Normally, perhaps with a signal."
rescue Exception => boom
 logger.error "Swift Ended Abnormally: #{boom}"
 logger.error boom.backtrace
end

logger.info "Busme! Swifty Exiting"
logger.info "Done."

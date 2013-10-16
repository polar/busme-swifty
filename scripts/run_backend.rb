#!/usr/bin/env ruby
require File.expand_path("../config/initialize.rb", File.dirname(__FILE__))

require 'net/http'
require "swiftcore/Swiftiply"

frontend_name = nil
backend_name = nil
OptionParser.new do |opts|
  opts.banner = 'Usage: run_backend.rb [options]'
  opts.separator ''
  opts.on('--name [NAME]', String, 'The name of this backend. It must be configured.') do |slug|
    backend_name = slug
  end
end.parse!


backend = Backend.find_by_name(backend_name) if backend_name

if backend.nil?
  puts "Backend #{backend_name} does not exist."
  exit 1
end

def stop_proxy(signal)
  puts "Stopping due to Signal #{signal}" if @logger
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
config['timeout']             = backend.timeout || 15
config['map']                 = [{}]
config['map'][0]['incoming']  = ["#{backend.cluster_address}:#{backend.cluster_port}"]
config['map'][0]['outgoing']  = ["#{backend.address}:#{backend.port}"]
config['map'][0]['keepalive'] = true
config['map'][0]['default']   = true
config['map'][0]['key']       = ENV["SWIFTIPLY_KEY"]


begin
  Swiftcore::Swiftiply.run(config)
rescue Exception => boom
end

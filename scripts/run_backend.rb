#!/usr/bin/env ruby
require File.expand_path("../config/initialize.rb", File.dirname(__FILE__))

require 'net/http'


backend_name = ARGV[0]

backend = Backend.find_by_name(backend_name) if backend_name

if backend.nil?
  puts "Backend #{backend_name} does not exist."
  exit 1
end

def stop_proxy(signal)
  puts "Stopping due to Signal #{signal}"
  File.delete("tmp/pids/backend-#{backend.name}.pid")
end

backend.remote_configuration.each_pair {|k,v| ENV[k] = v}

  # There should only be one swift per backend. All server proxies
  # differ in their server_endpoints.
  server_proxy = backend.server_proxies.where(:proxy_type => "Swift").first
  if server_proxy
      puts "Starting Swift Cluster Proxy on #{server_proxy.local_proxy_address} with backend #{server_proxy.local_backend_address}"
      proxy_address = server_proxy.local_proxy_address
      /((.*):)?(.*)/.match proxy_address
      cluster_address = match[2] || "127.0.0.1"
      cluster_port = match[3]

      connect_address = server_proxy.local_backend_address
      /((.*):)?(.*)/.match connect_address
      backend_address = match[2] || "0.0.0.0"
      backend_port = match[3]
      # Swiftiply catches these signals. However, these are here
      # if we receive them before we start Swiftiply.
      trap("HUP") { stop_proxy("HUP") }
      trap("INT") { stop_proxy("INT") }
      trap("QUIT") { stop_proxy("QUIT") }
      trap("TERM") { stop_proxy("TERM") }

      config = {}
      config['daemonize'] = false
      config['logger'] = { 'type' => "stderror", 'level' => 3}
      config['cluster_address']     = cluster_address
      config['cluster_port']        = cluster_port
      config['backend_address']     = backend_address
      config['backend_port']        = backend_port
      config['timeout']             = 30
      config['map']                 = [{}]
      config['map'][0]['incoming']  = ["#{cluster_address}:#{cluster_port}"]
      config['map'][0]['outgoing']  = ["#{backend_address}:#{backend_port}"]
      config['map'][0]['keepalive'] = true
      config['map'][0]['default']   = true
      config['map'][0]['key']       = ENV["SWIFTIPLY_KEY"]

      begin
        Swiftcore::Swiftiply.run(config)
      rescue Exception => boom
      end
  end
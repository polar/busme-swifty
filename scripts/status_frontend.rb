#!/usr/bin/env ruby
require File.expand_path("../config/initialize.rb", File.dirname(__FILE__))

config = {}

OptionParser.new do |opts|
  opts.banner = 'Usage: deconfigure_frontend.rb [options]'
  opts.separator ''
  opts.on('--name [NAME]', String, 'The name of this frontend') do |fqdn|
    config["name"] = fqdn
  end
end.parse!

if ! config["name"].nil?
  frontend = Frontend.find_by_name(config["name"])
  if frontend
    frontend.listen_status = []
    frontend.listen_status += Rush.bash("netstat -tan | grep '0.0.0.0:80.*LISTEN'").split("\n")
    frontend.listen_status += Rush.bash("netstat -tan | grep '0.0.0.0:443.*LISTEN'").split("\n")

    frontend.connection_status = []
    frontend.connection_status += Rush.bash("netstat -tn | grep '0.0.0.0:80.*ESTABLISHED'").split("\n")
    frontend.connection_status += Rush.bash("netstat -tn | grep '0.0.0.0:443.*ESTABLISHED'").split("\n")
    frontend.save

    for be in frontend.backends do
      be.listen_status = Rush.bash("netstat -tan | grep '#{be.cluster_address}:#{be.cluster_port}.*LISTEN'").split("\n")
      be.connection_status = Rush.bash("netstat -tn | grep '#{be.address}:#{be.port}.*ESTABLISHED'").split("\n")
      be.save
    end
  else
    puts "Frontend #{config["name"]} does not exist."
    exit(1)
  end
end
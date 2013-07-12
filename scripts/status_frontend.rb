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

def eatme(m, xs)
  result = []
  for x in xs
    match = m.match(x)
    if (match)
      result += match[1]
    end
  end
  return result
end

if ! config["name"].nil?
  frontend = Frontend.find_by_name(config["name"])
  if frontend
    frontend.listen_status = []
    frontend.listen_status += eatme(/0.0.0.0:80.*LISTEN/, Rush.bash("netstat -tan").split("\n"))
    frontend.listen_status += eatme(/0.0.0.0:443.*LISTEN/, Rush.bash("netstat -tan").split("\n"))

    puts "STATUS LENGTH #{frontend.listen_status.length}"
    if frontend.listen_status.length == 0
      frontend.listen_status = ["NONE"]
    end
    frontend.connection_status = []
    frontend.connection_status += eatme(/0.0.0.0:80.*ESTABLISHED/, Rush.bash("netstat -tan").split("\n"))
    frontend.connection_status += eatme(/0.0.0.0:443.*ESTABLISHED/, Rush.bash("netstat -tan").split("\n"))
    frontend.save

    for be in frontend.backends do
      be.listen_status += eatme(/#{be.cluster_address}:#{be.cluster_port}.*LISTEN/, Rush.bash("netstat -tn").split("\n"))
      be.connection_status += eatme(/#{be.address}:#{be.port}.*ESTABLISHED/, Rush.bash("netstat -tn").split("\n"))
      be.save
    end
  else
    puts "Frontend #{config["name"]} does not exist."
    exit(1)
  end
end
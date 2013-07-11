#!/usr/bin/env ruby
require File.expand_path("../config/initialize.rb", File.dirname(__FILE__))

config = {}
config["host_type"] = "ec2"

OptionParser.new do |opts|
  opts.banner = 'Usage: configure_frontend.rb [options]'
  opts.separator ''
  opts.on('--name [FQDN]', String, 'The fqdn or host ip that this is a frontend for swifty clusters') do |fqdn|
    config["host"] = fqdn
  end
  opts.on('--host [FQDN]', String, 'The fqdn or host ip that this is a frontend for swifty clusters') do |fqdn|
    config["host"] = fqdn
  end
end.parse!

frontend = Frontend.find_by_name(config["host"])
if frontend
  puts "Frontend #{frontend.name} already exists."
else
  frontend = Frontend.new(config)
end

if !frontend.configured
  puts "Configuring Frontend #{frontend.name}"
  begin
    hostip = Net::HTTP.get(URI.parse('http://myexternalip.com/raw'))
    frontend.hostip = hostip
  rescue Exception => boom1
    puts "Cannot establish external IP: #{boom1}"
  end
  frontend.configured = true
else
  puts "Frontend #{frontend.name} is already configured."
end

if frontend.valid?
  frontend.save
  puts "Frontend #{frontend.name} is configured"
end

puts "#{frontend.name}"
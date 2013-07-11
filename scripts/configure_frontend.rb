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

if config["hostip"].nil?
  config["hostip"] = hostip
end

if config["host"].nil?  && config["hostip"]
  logger.info "External Host IP: #{hostip}"
  config["host"] = hostip
end

frontend = Frontend.find_by_name(config["host"])
if frontend
  logger.info "Frontend #{frontend.name} already exists."
else
  frontend = Frontend.new(config)
end

if !frontend.configured
  begin
    hostip = Net::HTTP.get(URI.parse('http://myexternalip.com/raw'))
    frontend.hostip = hostip
  rescue Exception => boom1
    logger.error "Cannot establish external IP: #{boom1}"
  end
  frontend.configured = true
end

if frontend.valid?
  frontend.save
  logger.info "Frontend #{frontend.name} is configured"
end

puts "#{frontend.name}"
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
  puts "Frontend #{frontend.name} exists."
else
  frontend = Frontend.new(config)
end

puts Rush.bash("script/configure_frontend.sh --name #{frontend.name}")

puts Rush.bash("rm -rf backends.d/*.conf")
puts Rush.bash("rm -rf backends.d/*.location")
puts Rush.bash("rm -rf start.d/*.sh")
for be in frontend.backends do
  puts Rush.bash("scripts/configure_backend.sh --name #{be.name}")
end

puts Rush.bash("scripts/restart_frontend.sh")
puts "#{frontend.name}"
#!/usr/bin/env ruby
require File.expand_path("../config/initialize.rb", File.dirname(__FILE__))

config = {}

OptionParser.new do |opts|
  opts.banner = 'Usage: deconfigure_backend.rb [options]'
  opts.separator ''
  opts.on('--name [NAME]', String, 'The name of this backend') do |fqdn|
    config["name"] = fqdn
  end
end.parse!

if ! config["name"].nil?
  backend = Backend.find_by_name(config["name"])
  if backend
    puts Rush.bash("rm -f backends.d/#{backend.name}.conf")
    puts Rush.bash("rm -f backends.d/#{backend.name}.location")
    puts Rush.bash("rm -f start.d/#{backend.name}.sh")
    backend.configured = false
    backend.save
  end
end
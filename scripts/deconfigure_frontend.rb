#!/usr/bin/env ruby
require File.expand_path("../config/initialize.rb", File.dirname(__FILE__))

config = {}

OptionParser.new do |opts|
  opts.banner = 'Usage: deconfigure_frontend.rb [options]'
  opts.separator ''
  opts.on('--name [NAME]', String, 'The name of this front') do |fqdn|
    config["name"] = fqdn
  end
end.parse!

if ! config["name"].nil?
  frontend = Frontend.find_by_name(config[:name])
  if frontend
    if ! frontend.backends.empty?
      frontend.configured = false
      frontend.save
    else
      puts "Frontend #{frontend.name} still has #{frontend.backends.count} backends."
    end
  else
    puts "Frontend still has backends"
    exit(1)
  end
end
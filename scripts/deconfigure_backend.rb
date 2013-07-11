#!/usr/bin/env ruby
require "../config/initialize"

config = {}

OptionParser.new do |opts|
  opts.banner = 'Usage: deconfigure_backend.rb [options]'
  opts.separator ''
  opts.on('--name [NAME]', String, 'The name of this backend') do |fqdn|
    config["name"] = fqdn
  end
end.parse!

if ! config["name"].nil?
  backend = Backend.find_by_name(config[:name])
  if backend
    Rush["/etc/nginx/conf.d/#{backend.name}.conf"].destroy
    Rush["~ec2-user/busme-swifty/start.d/#{backend.name}.sh"].destroy
    backend.configured = false
    backend.save
  end
end
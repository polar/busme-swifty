#!/usr/bin/env ruby
require File.expand_path("../config/initialize.rb", File.dirname(__FILE__))

# The only argument is the name of the Frontend.

frontend = Frontend.find_by_name(ARGV[0])
if frontend.nil?
  puts "Frontend #{ARGV[0]} does not exist."
  exit 1
end

puts "Configuring Frontend #{frontend.name}"
begin
  hostip = Net::HTTP.get(URI.parse('http://myexternalip.com/raw'))
  frontend.external_ip = hostip
  puts "Configuring Frontend #{frontend.name} is on #{hostip}"
rescue Exception => boom1
  puts "Cannot establish external IP: #{boom1}"
end
if frontend.valid?
  frontend.save
  puts "Frontend #{frontend.name} is configured"
else
  puts "frontend #{frontend.name} is not valid!"
  puts "#{frontend.errors.inspect}"
end

FileUtils.mkdir_p "backends.d"
FileUtils.mkdir_p "start.d"
FileUtils.mkdir_p "log"
FileUtils.mkdir_p "tmp/pids"

frontend.backends.each do |backend|
  puts "Configuring backend #{backend.name}"
  puts Rush.bash("#{backend.configure_command} #{backend.name}")
end

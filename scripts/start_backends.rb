#!/usr/bin/env ruby
require File.expand_path("../config/initialize.rb", File.dirname(__FILE__))

frontend_name = nil
OptionParser.new do |opts|
  opts.banner = 'Usage: start_backends.rb [options]'
  opts.separator ''
  opts.on('--name [NAME]', String, 'The name of this frontend. It must be configured.') do |slug|
    frontend_name = slug
  end
end.parse!

frontend = Frontend.find_by_name(frontend_name) if frontend_name

if frontend.nil?
  puts "Frontend #{frontend_name} does not exist."
  exit 1
end

puts "Stopping Backend for Frontend #{frontend.name}."

for be in frontend.backends do
  puts Rush.bash("start.d/#{be.name}.sh")
end

#!/usr/bin/env ruby
require File.expand_path("../config/initialize.rb", File.dirname(__FILE__))

frontend_name = nil
backend_name = nil
OptionParser.new do |opts|
  opts.banner = 'Usage: stop_backend.rb [options]'
  opts.separator ''
  opts.on('--name [NAME]', String, 'The name of this backend. It must be configured.') do |slug|
    backend_name = slug
  end
end.parse!


backend = Backend.where(:backend_name => backend_name).first

if backend.nil?
  puts "Backend #{backend_name} does not exist."
  exit 1
end

processes = Rush.processes.filter(:cmdline => /run_backend.rb.*--name\s*#{backend_name}/)

puts "There are #{processes.count} processes to kill."
for p in processes do
  puts "Killing #{p.pid}."
  p.kill()
end

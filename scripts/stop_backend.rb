#!/usr/bin/env ruby
require File.expand_path("../config/initialize.rb", File.dirname(__FILE__))

backend_name = ARGV[1]
backend = Backend.find_by_name(backend_name) if backend_name

if backend.nil?
  puts "Backend #{backend_name} does not exist."
  exit 1
end

processes = Rush.processes.filter(:cmdline => /run_backend.rb\s*#{backend_name}/)

puts "There are #{processes.count} processes to kill."
for p in processes do
  puts "Killing #{p.pid}."
  p.kill("QUIT")
end

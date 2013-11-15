#!/usr/bin/env ruby
require File.expand_path("../config/initialize.rb", File.dirname(__FILE__))

# The only argument is the name of the Frontend.

frontend = Frontend.find_by_name(ARGV[0])
if frontend.nil?
  puts "Frontend #{ARGV[0]} does not exist."
  exit 1
end

puts "Frontend #{frontend.name} has #{frontend.backends.count} Backends"
frontend.backends.each do |backend|
  puts "Starting Backend #{backend.name}"
  puts Rush.bash("#{backend.start_command} #{backend.name}")
end
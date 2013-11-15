#!/usr/bin/env ruby
require File.expand_path("../config/initialize.rb", File.dirname(__FILE__))

# The only argument is the name of the Frontend.

frontend = Frontend.find_by_name(ARGV[0])
if frontend.nil?
  puts "Frontend #{ARGV[0]} does not exist."
  exit 1
end

frontend.backends.each do |backend|
  puts Rush.bash("#{backend.stop_command} #{backend.name}")
end
#!/usr/bin/env ruby
require File.expand_path("../config/initialize.rb", File.dirname(__FILE__))

frontend_name = ARGV[1]
frontend = Frontend.find_by_name(frontend_name)
if frontend.nil?
  puts "Frontend #{frontend_name} does not exist."
  exit 1
end

if frontend.backends.empty?
  puts "Frontend #{frontend.name} is deconfigured."
else
  puts "Frontend #{frontend.name} still has #{frontend.backends.count} backends."
end
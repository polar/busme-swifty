#!/usr/bin/env ruby
require File.expand_path("../config/initialize.rb", File.dirname(__FILE__))

backend_name = ARGV[0]

backend = Backend.find_by_name(backend_name) if backend_name

if backend.nil?
  puts "Backend #{backend_name} does not exist."
  exit 1
end

puts Rush.bash("backends.d/#{backend.name}.sh")

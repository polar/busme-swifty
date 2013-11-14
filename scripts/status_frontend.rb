#!/usr/bin/env ruby
require File.expand_path("../config/initialize.rb", File.dirname(__FILE__))

frontend_name = ARGV[1]

def array_match(m, xs)
  result = []
  for x in xs do
    match = m.match(x)
    if (match)
      result << match[1]
    end
  end
  return result
end

frontend = Frontend.find_by_name(frontend_name)
if frontend.nil?
  puts "Frontend #{frontend_name} does not exist."
  exit(1)
end

  netstat = Rush.bash("netstat -tan").split("\n")
  frontend.git_commit = Rush.bash("git log --max-count=1").split("\n").take(3)

  frontend.listen_status = []
  frontend.listen_status += array_match(/([0-9a-f\:\.]*:80.*LISTEN)/, netstat)
  frontend.listen_status += array_match(/([0-9a-f\:\.]*:443.*LISTEN)/, netstat)

  frontend.connection_status = []
  frontend.connection_status += array_match(/([0-9a-f\:\.]*:80.*ESTABLISHED)/, netstat)
  frontend.connection_status += array_match(/([0-9a-f\:\.]*:443.*ESTABLISHED)/, netstat)
  frontend.save

  for be in frontend.backends do
    be.listen_status = array_match(/(#{be.cluster_address}:#{be.cluster_port}).*LISTEN/, netstat)
    be.connection_status = array_match(/([0-9a-f\:\.]*:#{be.port}.*ESTABLISHED)/, netstat)
    be.save
  end
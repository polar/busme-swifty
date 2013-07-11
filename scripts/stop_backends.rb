#!/usr/bin/env ruby
require File.expand_path("../config/initialize.rb", File.dirname(__FILE__))

frontend_name = nil
backend_name = nil
OptionParser.new do |opts|
  opts.banner = 'Usage: stop_backend.rb [options]'
  opts.separator ''
  opts.on('--frontend-name [NAME]', String, 'The name of this fronend.') do |slug|
    frontend_name = slug
  end
end.parse!

frontend = Frontend.find_by_name(frontend_name) if frontend_name

if frontend.nil?
  puts "Frontend #{frontend_name} does not exist."
  exit 1
end

processes = Rush.processes.filter(:cmdline => /run_backend.rb.*--name\s*[AZ]-#{frontend_name}/)

for p in processes do
  puts "Killing #{p}"
  p.kill()
end

#!/usr/bin/env ruby
require "../config/initialize"

frontend_name = nil
backend_name = nil
OptionParser.new do |opts|
  opts.banner = 'Usage: stop_backend.rb [options]'
  opts.separator ''
  opts.on('--backend-name [NAME]', String, 'The name of this backend. It must be configured.') do |slug|
    backend_name = slug
  end
end.parse!


backend = Backend.where(:backend_name => backend_name).first

if backend.nil?
  logger.error "Backend #{backend_name} does not exist."
  exit 1
end

processes = Rush.processes.filter(:cmdline => /run_backend.rb.*--name\s*#{backend_name}/)

for p in processes do
  p.kill()
end

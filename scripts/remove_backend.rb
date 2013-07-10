#!/usr/bin/env ruby
require "../config/initialize"

frontend_name = nil
backend_name = nil
OptionParser.new do |opts|
  opts.banner = 'Usage: stop_backend.rb [options]'
  opts.separator ''
  opts.on('--frontend-name [NAME]', String, 'The name of the frontend of this backend.') do |slug|
    frontend_name = slug
  end
  opts.on('--backend-name [NAME]', String, 'The name of this backend. It must be configured.') do |slug|
    backend_name = slug
  end
end.parse!

frontend = Frontend.find_by_name(frontend_name)
if frontend.nil?
  logger.error "Frontend #{frontend_name} does not exist."
  exit 1
end

backend = Backend.where(:frontend_id => frontend.id, :backend_name => backend_name).first

if backend.nil?
  logger.error "Backend #{backend_name} does not exist for #{frontend_name}."
  exit 1
end

processes = Rush.processes.filter(:cmdline => /.*#{frontend_name}.*#{backend_name}/)

for p in processes do
  p.kill()
end

startfile = File.expand_path("../start.d/#{backend.name}.sh", __FILE__);
conffile = "/etc/nginx/conf.d/#{backend.name}.conf"

FileUtils.rm(startfile)
FileUtils.rm(conffile)

logger.info "Backend #{backend_name} destroyed."
backend.destroy
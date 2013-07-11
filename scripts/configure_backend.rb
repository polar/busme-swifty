#!/usr/bin/env ruby
require File.expand_path("../config/initialize.rb", File.dirname(__FILE__))

config = {}
config["frontend_address"] = "0.0.0.0"
config["backend_address"]  = "0.0.0.0"
config["cluster_address"]  = "127.0.0.1"

OptionParser.new do |opts|
  opts.banner = 'Usage: configure_backend.rb [options]'
  opts.separator ''
  opts.on('--name [NAME]', String, 'The name of this backend') do |fqdn|
    config["name"] = fqdn
  end
  opts.on('--frontend-name [NAME]', String, 'The name of the frontend that is fronting for this backend') do |fqdn|
    config["frontend_name"] = fqdn
  end
  opts.on('--frontend-address [ADDRESS]', String, 'The IP address that nginx will listen for connections on. Ports will be 80/443. Default 0.0.0.0') do |address|
    config['address'] = address
  end
  opts.on('--master-slug [NAME]', String, 'The slug of master that this backend is serving.') do |address|
    config['master_slug'] = address
  end
  opts.on('--base_hostname [NAME]', String, 'The hostname that matches this backend. If master master_slug it should be master_slug.hostname') do |address|
    config['base_hostname'] = address
  end
  opts.on('--server-name [name]', String, 'The alternate hostname that matches this backend.') do |address|
    config['server_name'] = address
  end
  opts.on('--cluster-address [ADDRESS]', String, 'The hostname/IP address that Busme! Swifty will listen for connections on. Default 127.0.0.1') do |address|
    config['cluster_address'] = address
  end
  opts.on('--cluster-port [PORT]', String, 'The port that Busme! Swifty will listen for connections on.') do |port|
    config['cluster_port'] = port
  end
  opts.on('--backend-address [ADDRESS]', String, 'The hostname/IP address to which Busme! swifty web runners connect. Default 0.0.0.0') do |address|
    config['address'] = address
  end
  opts.on('--backend-port [PORT]', String, 'The port to which Busme! swifty web runners connect.') do |address|
    config['port'] = port
  end
  opts.on('-t', '--timeout [SECONDS]', String, 'The server unavailable timeout.  Defaults to 3 seconds.') do |timeout|
    config['timeout'] = timeout
  end
end.parse!

if config["name"].nil?
  if config["frontend-name"].nil?
    begin
      hostip = Net::HTTP.get(URI.parse('http://myexternalip.com/raw'))
    rescue Exception => boom1
      puts "Cannot establish external IP: #{boom1}"
      exit 1
    end

    if hostip.nil?
      puts "Cannot establish external IP"
      exit 1
    end
    puts "External Host IP: #{hostip}"
    config["frontend_name"] = hostip
  end

  frontend = Frontend.find_by_name("#{config["frontend_name"]}")
  if frontend.nil?
    # We are already configured.
    puts "Frontend #{frontend.name} does not exist."
    exit 1
  end

  config["frontend"] = frontend
  if config["base_hostname"]
    if config["master_slug"]
      config["hostname"] = "#{config["master_slug"].config["base_hostname"]}"
    else
      config["hostname"] = config["base_hostname"] if config["hostname"].nil?
    end
  else
    config["hostname"] = frontend.hostname if config["hostname"].nil?
  end

  if ! config["master_slug"].blank?
    name = "A-#{frontend.name}-#{config["hostname"]}-#{config["frontend_address"]}-#{config["cluster_address"]}-#{config["cluster_port"]}-#{config["backend_address"]}-#{config["backend-port"]}"
  else
    name = "Z-#{frontend.name}-#{config["hostname"]}-#{config["frontend_address"]}-#{config["cluster_address"]}-#{config["cluster_port"]}-#{config["backend_address"]}-#{config["backend-port"]}"
  end
  backend = Backend.find_by_name(name)
  if backend.nil?
    backend = Backend.new(config)
    if backend.valid?
      backend.save
    end
  end
else
  name = config["name"]
  backend = Backend.find_by_name(name)
  if backend.nil?
    puts "Backend #{name} does not exist."
    exit 1
  end
end
puts "Creating backend config files from #{Dir.pwd}."

Rush.bash("scripts/create_backend_configfiles.sh '#{backend.frontend.name}' '#{backend.name}' '#{backend.frontend_address}' '#{backend.master_slug}' '#{backend.hostname}' '#{backend.server_name}' '#{backend.cluster_address}' '#{backend.cluster_port}' '#{backend.address}' '#{backend.port}'")

backend.configured = true
backend.save

puts "#{backend.name}"

#!/usr/bin/env ruby
require File.expand_path("../config/initialize.rb", File.dirname(__FILE__))


  def configuration_nginx(backend)
    nginx_servers = backend.proxy_addresses.map { |addr| "server #{addr};" }
    upstream      =
    "
      upstream #{backend.name} {
          #{nginx_servers.join("\n          ")}
       }
    "

    locations = backend.locations.map do |location|
    "
          location ^~ /#{location}/ {
              proxy_set_header  X-Real-IP  $remote_addr;
              proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header  Host $http_host;
              proxy_redirect    off;
              proxy_pass        http://#{backend.name};
          }
    "
    end

    nginx_servernames = "server_name #{backend.hostnames.join(" ")}"

    "
    #{upstream}

      server {
          listen       80;
          #{nginx_servernames};
          access_log  /var/log/nginx/#{backend.name}.log  main;

    #{locations.join("\n")}

          location / {
              proxy_set_header  X-Real-IP  $remote_addr;
              proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header  Host $http_host;
              proxy_redirect    off;
              proxy_pass        http://#{backend.name};
          }
      }

      server {
          listen       443;
          #{nginx_servernames};
          access_log  /var/log/nginx/@NAME.log  main;

          ssl                  on;
          ssl_certificate      /etc/ssl/certs/web-host.pem;
          ssl_certificate_key  /etc/ssl/private/web-host.key;

          ssl_session_timeout  5m;

          ssl_protocols  SSLv2 SSLv3 TLSv1;
          ssl_ciphers  HIGH:!aNULL:!MD5;
          ssl_prefer_server_ciphers   on;

    #{locations.join("\n")}

          location / {
              proxy_set_header  X-Real-IP  $remote_addr;
              proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header  Host $http_host;
              proxy_redirect    off;
              proxy_pass        http://#{backend.name};
          }
      }
  "
  end

  def configuration_start(backend)
    case backend.deployment_type
      when "swift"
        "
cd ~/#{frontend.git_name}
bundle install

# Backend #{backend.name}

echo \"Starting #{backend.name}\" > /var/log/swifty/#{backend.name}.log
bundle exec ruby scripts/run_backend.rb #{backend.name} >> /var/log/swifty/#{backend.name}.log 2>&1  &
echo $! > /var/run/swifty/#{backend.name}.pid
ps alx | grep `cat /var/run/swifty#{backend.name}.pid` >> /var/log/swifty/#{backend.name}.log
echo PID IS `cat /var/run/swifty/#{backend.name}.pid` >> /var/log/swifty/#{backend.name}.log
echo Backend #{backend.name} started with PID `cat /var/run/swifty/#{backend.name}.pid`
"
    end
  end

  def configure_start(backend)
    conf = configuration_start(backend)
    if conf
      fname = File.expand_path("../start.d/backend-#{backend.name}.sh", File.dirname(__FILE__))
      file = File.open(fname, "w+")
      file.write(conf)
      file.close
    end
  end


  def configure_nginx(backend)
    conf = configuration_nginx(backend)
    fname = File.expand_path("../backends.d/backend-#{backend.name}.conf", File.dirname(__FILE__))
    file = File.open(fname, "w+")
    file.write(conf)
    file.close
  end

# The only argument is the name of the Backend.

backend = Backend.find_by_name(ARGV[0])
if backend.nil?
  puts "Backend #{backend.name} does not exist."
  exit 1
end

case backend.frontend.deployment_type
  when "unix-nginx"
    configure_nginx(backend)
    confgiure_start(backend)
  when "unix"
    configure_nginx(backend)
    confgiure_start(backend)
end

puts "Backend #{backend.name} is configured."
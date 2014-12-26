root = "#{Dir.getwd}"

activate_control_app "tcp://127.0.0.1:9293"
bind "unix://#{root}/tmp/pids/puma.sock"
pidfile "#{root}/tmp/pids/puma.pid"
rackup "#{root}/config.ru"
state_path "#{root}/tmp/pids/puma.state"

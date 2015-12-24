class Nagira < Sinatra::Base
  set :app_file, __FILE__

  Dir["#{Nagira::BASE}/app/parsers/*.rb"].each { |file| require file }

  ##
  # Do some necessary tasks at start and then run Sinatra app.
  #
  # @method   startup_configuration
  # @overload before("Initial Config")
  configure do

    Parser.config   = settings.nagios_cfg
    Parser.status   = settings.status_cfg   || Parser.config.status_file
    Parser.objects  = settings.objects_cfg  || Parser.config.object_cache_file
    Parser.commands = settings.command_file || Parser.config.command_file

    BackgroundParser.ttl    = ::DEFAULT[:ttl].to_i
    BackgroundParser.start  = ::DEFAULT[:start_background_parser]

    Logger.log "Starting Nagira application"
    Logger.log "Version #{Nagira::VERSION}"
    Logger.log "Running in #{Nagira.settings.environment} environment"

    Parser.state.to_h.keys.each do |x|
      Logger.log "Using nagios #{x} file: #{Parser.state[x].path}"
    end

    BackgroundParser.run if BackgroundParser.configured?
  end

end

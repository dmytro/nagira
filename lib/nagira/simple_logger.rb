class Nagira < Sinatra::Base
  # Simple logger helper. Use as: Logger.log(message)
  class Logger
    include Singleton

    # Print log message to stdout with optional warning tag
    def self.log(message, warning=false)
      puts "[#{Time.now}] -- #{ "WARNING:" if warning } #{message}"
    end
  end
end

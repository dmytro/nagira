# Simple logger helper. Use as: SimpleLogger.log(message)
class SimpleLogger
  include Singleton

  # Print log message to stdout with optional warning tag
  def self.log(message, warning=false)
    puts "[#{Time.now}] -- #{ "WARNING:" if warning } #{message}"
  end
end

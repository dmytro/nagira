class Nagira < Sinatra::Base
  ##
  # When this prefix added to routes convert output to ActiveResource
  # compatible format (basically Array instead of Hash).
  #
  AR_PREFIX = "/ar"

  class Api
    # Get all routes that Nagira provides.
    def self.show
      api = { }

      param_regex = Regexp.new '\(\[\^\\\\\/\?\#\]\+\)'
      Nagira.routes.keys.each do |method|
        api[method] ||= []
        Nagira.routes[method].each do |r|
          path = r[0].inspect[3..-3]
          r[1].each do |parm|
            path.sub!(param_regex,":#{parm}")
          end
          path.gsub!('\\','')
          api[method] << path unless path.empty?
        end
      end
      api
    end
  end
end

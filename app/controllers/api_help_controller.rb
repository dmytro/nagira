class Nagira < Sinatra::Base

  class ApiHelpController
    # Get all routes that Nagira provides.
    def self.get
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

#
# PUT method routes for notifications.
#
class Nagira < Sinatra::Base

  put "/_notifications/:host_name/:service_description" do

    data, result = [], true

    @input.each do |datum|
      update = {}
      if datum['command'] == 'enable'
        update = enable_svc_notifications(
                    'host_name' => params['host_name'],
                    'service_description' => params['service_description']
                 )
      elsif datum['command'] == 'disable'
        update = disable_svc_notifications(
                    'host_name' => params['host_name'],
                    'service_description' => params['service_description']
                 )
      end
      data << update[:object].first
      result &&= update[:result]
    end
    @data = { result: result, object: data }
    nil

  end

end

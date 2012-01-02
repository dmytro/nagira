#
# Send output to user in specified format
#
def respond_with data, format

  format = (format || :xml).to_sym

  if !data || data == ''
    data   = {:message => "Object not found", :error => "HTTP::Notfound"}
    stat = 404
  end

  content_type "application/#{format.to_s}"
  status stat || 200

  case format
  when :xml, :json, :yaml  
    body data.send("to_#{format}")
  else            
    content_type "text/plain"
    body "Error: Only XML, JSON and YAML output formats supported\n"
    status 415
  end
end

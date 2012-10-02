class Nagira < Sinatra::Base

  # Helper to send PUT update to Nagios::ExternalCommands
  #
  # @param [Hash] params 
  # @param [Array] required List of required paramaters for this action
  # @param [Symbol] action Nagios external command name
  def put_update action, params
    
    if $nagios[:commands].send(params.merge({ :action => action }))
      { :status => 'OK', :object => params}
    else
      { :status => "FAILED", :object => params }
    end
  end
  
end

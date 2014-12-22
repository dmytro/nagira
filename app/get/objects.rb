class Nagira < Sinatra::Base
  #
  # Objects routes
  # ============================================================

  ##
  # @method get_objects
  #
  # Get full list of Nagios objects. Returns hash containing all
  # configured objects in Nagios: hosts, hostgroups, services,
  # contacts. etc.
  #
  # @macro accepted
  # @macro list
  #
  get "/_objects" do

    @data = begin
              @output == :list ? @objects.keys : @objects
            rescue NoMethodError
              nil
            end
    nil
  end

  ##
  # @method   get_object_type
  # @!macro type
  #
  # Get all objects of type :type
  #
  # @!macro accepted
  # @!macro list
  #
  #
  get "/_objects/:type" do |type|
    begin
      @data = @objects[type.to_sym]
      @data = @data.keys if @output == :list

    rescue NoMethodError
      nil
    end

    nil
  end

  ##
  # @method get_1_object
  #
  # Get single Nagios object.
  #
  # @!macro type
  # @!macro name
  #
  # @!macro accepted
  # * none
  #
  get "/_objects/:type/:name" do |type,name|
    begin
      @data = @objects[type.to_sym][name]
    rescue NoMethodError
      nil
    end

    nil
  end
end

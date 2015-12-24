class Nagira < Sinatra::Base
  include OutputTypeable
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
    body_with_list @objects
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
    body_with_list @objects[type.to_sym]
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
    @objects[type.to_sym][name]
  end
end

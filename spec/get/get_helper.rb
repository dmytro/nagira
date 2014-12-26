require 'spec_helper'

IMPLEMENTED = {
  top:            %w{ _api _status _objects _config _runtime},
  output:         %w{ _list _state _full }, # Type of requests as in varaible @output
  hosts:          %w{ archive tv },
  status:         %w{ _services _servicecomments _hostcomments },
  objects:        %w{ timeperiod command contactgroup hostgroup contact host service }
}

#
# Specs for implemetned API endpoints. Only check response: OK or 404.
#

shared_examples_for :fail_on_random_url do |base|
  RANDOM.each do |url|
    ep = "#{base}/#{url}"
    it "fails on '#{ep}' string" do
      get ep
      last_response.status.should be 404
    end
  end
end

shared_examples_for :respond_to_valid_url do |base, urls, custom_regex|

  case urls
    when Array
    urls.each do |url|
      ep = "#{base}/#{url}"
      it "responds to #{ep}" do
        get ep
        last_response.should be_ok
      end
    end
    when nil
      ep = "#{base}"
      it "responds to #{ep}" do
        get ep
        last_response.should be_ok
      end
  end
end

shared_examples_for :fail_on_bad_url do |url|
  before {  get url }
  it "fails on #{url}" do
    last_response.status.should be 404
  end
end

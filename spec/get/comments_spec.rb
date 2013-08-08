require 'spec_helper'


shared_examples_for :comment_data do 

  let(:data) { JSON.parse(last_response.body) }

  subject do
    case data
    when Array
      data.first
    when Hash
      data.values.first.first
    end
  end

  it { should be_a_kind_of Hash }
  it { should have_key 'comment_id' }
  it { should have_key 'comment_data' }
  it { should have_key 'author' }  

end


describe Nagira do 
  
  set :environment, ENV['RACK_ENV'] || :test
  include Rack::Test::Methods
  def app 
    @app ||= Nagira
  end
  
  before :all do
    get "/_status/_list.json"
    @host = JSON.parse(last_response.body).first
  end

  context "/_status/:host/_hostcomments" do 
    before {  get "/_status/#{@host}/_hostcomments.json" }
    it_should_behave_like :comment_data    
  end


  context "/_status/:host/_servicecomments" do 
    before { get "/_status/#{@host}/_servicecomments.json" }

    it_should_behave_like :comment_data

    let (:data) {  JSON.parse(last_response.body).values.first.first }
    it { data.should have_key 'service_description' }
    it { data.should have_key 'host_name' }

  end


    
end

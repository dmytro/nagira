shared_examples_for :json_response do 
  
  context "data structure" do

    before (:each) do 
      @ret = JSON.parse(last_response.body)
    end
    
    subject { @ret }

    it "should be an Array" do 
      should be_a_kind_of Array
    end

    it { subject.first.should have_key "status" }
    it { subject.first.should have_key "object" }

  end
end

shared_examples_for :nagios_cmd_file do
  before :each do 
    File.delete nagios_cmd rescue nil
  end
  
  it "writes to nagios.cmd file" do
    File.should_not exist(nagios_cmd)
    put url, @data.to_json, content_type
    File.should exist(nagios_cmd)
    File.read(nagios_cmd).should =~ /^\[\d+\] PROCESS_SERVICE_CHECK_RESULT;#{@host}/
  end
  
end

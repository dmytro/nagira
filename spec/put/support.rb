shared_examples_for :json_response do 
  before (:each) do 
    @ret = JSON.parse(last_response.body)
  end
  subject { @ret }
  
  it { should be_a_kind_of Hash }
  it { should have_key "result" }
  it { should have_key "object" }

  let (:obj) {  subject["object"] }

  context :object do
    # subject { obj }
    
    it { obj.should be_a_kind_of Array }
    it { 
      obj.each { |x| x.should be_a_kind_of Hash }
    }

    context :data_keys do
      
      it do
        obj.each do |x| 
          x.should have_key "data"
          x.should have_key "result"
          x.should have_key "messages"
          [true, false].should include x["result"]
        end
      end
    end
  end
end

shared_examples_for :json_success_response do
  before (:each) do 
    @ret = JSON.parse(last_response.body)
  end
  subject { @ret }
  
end

shared_examples_for :write_to_nagios_cmd_file do
  before (:all) do 
      File.delete $nagios[:commands].path rescue nil
  end
  let (:cmd) { $nagios[:commands].path }
  
  it "writes to nagios.cmd file" do
    File.should exist(cmd)
    File.read(cmd).should =~ /^\[\d+\] PROCESS_(SERVICE|HOST)_CHECK_RESULT;#{host}/
  end

  after (:each) do 
      File.delete $nagios[:commands].path rescue nil
  end
end


shared_examples_for :put_status do 
      it_should_behave_like :json_response
      it_should_behave_like :write_to_nagios_cmd_file
end

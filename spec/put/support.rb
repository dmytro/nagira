shared_examples_for :json_response do 
  before (:each) do 
    @ret = JSON.parse(last_response.body)
  end
  subject { @ret }
  
  it { should be_a_kind_of Hash }
  it { should have_key "result" }
  it { should have_key "object" }
end

shared_examples_for :json_success_response do
  before (:each) do 
    @ret = JSON.parse(last_response.body)
  end
  subject { @ret }
  
  #it {  subject.}
end

shared_examples_for :write_to_nagios_cmd_file do
  before (:all) do 
      File.delete $nagios[:commands].path rescue nil
  end
  let (:cmd) { $nagios[:commands].path }
  
  it "writes to nagios.cmd file" do
    File.should exist(cmd)
    File.read(cmd).should =~ /^\[\d+\] PROCESS_SERVICE_CHECK_RESULT;#{host}/
  end

  after (:each) do 
      File.delete $nagios[:commands].path rescue nil
  end
end


shared_examples_for :put_status do 
      it_should_behave_like :json_response
      it_should_behave_like :write_to_nagios_cmd_file
end

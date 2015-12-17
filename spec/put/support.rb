shared_examples_for :json_response do
  before (:each) do
    @ret = JSON.parse(last_response.body)
  end
  subject { @ret }

  it { expect(subject).to be_a_kind_of Hash }
  it { expect(subject).to have_key "result" }
  it { expect(subject).to have_key "object" }

  let (:obj) {  subject["object"] }

  context :object do
    # subject { obj }

    it { expect(obj).to be_a_kind_of Array }
    it {
      obj.each { |x| expect(x).to be_a_kind_of Hash }
    }

    context :data_keys do

      it do
        obj.each do |x|
          expect(x).to have_key "data"
          expect(x).to have_key "result"
          expect(x).to have_key "messages"
          expect([true, false]).to include x["result"]
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
    File.delete ::Nagira::Parser.commands.path rescue nil
  end
  let (:cmd) { ::Nagira::Parser.commands.path }

  it "writes to nagios.cmd file" do
    expect(File).to exist(cmd)
    expect(File.read(cmd)).to match(/^\[\d+\] PROCESS_(SERVICE|HOST)_CHECK_RESULT;#{host}/)
  end

  after (:each) do
      File.delete ::Nagira::Parser.commands.path rescue nil
  end
end


shared_examples_for :put_status do
      it_should_behave_like :json_response
      it_should_behave_like :write_to_nagios_cmd_file
end

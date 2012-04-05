require "#{File.join(File.dirname(__FILE__),'..','spec_helper')}"

describe 'activemq' do
  let(:facts) { {:architecture => 'x86_64'} }

  context "when using default parameters" do
    it { should contain_service('activemq').with_ensure('running') }

    it 'should generate valid init.d' do
      expected = IO.read(File.expand_path('activemq-init.d', File.dirname(__FILE__)))
      content = catalogue.resource('file', '/etc/init.d/activemq').send(:parameters)[:content]
      content.should == expected
    end
  end

end

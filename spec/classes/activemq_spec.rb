require "#{File.join(File.dirname(__FILE__),'..','spec_helper')}"

describe 'activemq' do
  let(:facts) { {:architecture => 'x86_64'} }

  it { should contain_service('activemq').with_ensure('running') }

  context "when using default parameters" do
    it 'should generate valid init.d' do
      expected = IO.read(File.expand_path('activemq-init.d', File.dirname(__FILE__)))
      content = catalogue.resource('file', '/etc/init.d/activemq').send(:parameters)[:content]
      content.should == expected
    end
  end

  context "when using custom home" do
    let(:params) { {
      :home => '/usr/local'
    } }
    it 'should generate valid init.d' do
      expected = IO.read(File.expand_path('activemq-init.d-usrlocal', File.dirname(__FILE__)))
      content = catalogue.resource('file', '/etc/init.d/activemq').send(:parameters)[:content]
      content.should == expected
    end
  end

end

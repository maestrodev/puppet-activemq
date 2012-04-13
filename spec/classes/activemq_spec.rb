require "#{File.join(File.dirname(__FILE__),'..','spec_helper')}"

describe 'activemq' do
  let(:facts) { {:architecture => 'x86_64'} }

  it { should contain_service('activemq').with_ensure('running') }

  context "when using default parameters" do
    it 'should generate valid init.d' do
      should contain_file("/etc/init.d/activemq")
      expected = IO.read(File.expand_path('activemq-init.d', File.dirname(__FILE__)))
      content = catalogue.resource('file', '/etc/init.d/activemq').send(:parameters)[:content]
      content.should == expected
    end

    it "should generate a valid wrapper.conf" do
      should contain_file('wrapper.conf')
      content = catalogue.resource('file', 'wrapper.conf').send(:parameters)[:content]
      content.should =~ %r[ACTIVEMQ_HOME=/opt/activemq]
      content.should =~ %r[ACTIVEMQ_BASE=/opt/activemq]
      content.should =~ %r[wrapper.java.maxmemory=512]
    end
  end

  context "when using custom home" do
    let(:params) { {
      :home => '/usr/local'
    } }
    it 'should generate valid init.d' do
      should contain_file("/etc/init.d/activemq")
      expected = IO.read(File.expand_path('activemq-init.d-usrlocal', File.dirname(__FILE__)))
      content = catalogue.resource('file', '/etc/init.d/activemq').send(:parameters)[:content]
      content.should == expected
    end

    it "should generate a valid wrapper.conf" do
      should contain_file('wrapper.conf')
      content = catalogue.resource('file', 'wrapper.conf').send(:parameters)[:content]
      content.should =~ %r[ACTIVEMQ_HOME=/usr/local/activemq]
      content.should =~ %r[ACTIVEMQ_BASE=/usr/local/activemq]
    end
  end

  context "when using custom memory setting" do
    let(:params) { {
      :max_memory => '256'
    } }

    it "should generate a valid wrapper.conf" do
      should contain_file('wrapper.conf')
      content = catalogue.resource('file', 'wrapper.conf').send(:parameters)[:content]
      content.should =~ %r[wrapper.java.maxmemory=256]
    end
  end

end

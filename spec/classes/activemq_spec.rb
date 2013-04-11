require 'spec_helper'

describe 'activemq' do
  let(:facts) { {:architecture => 'x86_64'} }

  it { should contain_service('activemq').with_ensure('running') }

  context "when using default parameters" do
    it 'should generate valid init.d' do
      should contain_file("/etc/init.d/activemq")
      content = catalogue.resource('file', '/etc/init.d/activemq').send(:parameters)[:content]
      content.should match(%r[ACTIVEMQ_HOME="/opt/activemq"])
      content.should match(%r[WRAPPER_CMD="/opt/activemq/bin/linux-x86-64/wrapper"])
      content.should match(%r[WRAPPER_CONF="/opt/activemq/bin/linux-x86-64/wrapper.conf"])
      content.should match(%r[RUN_AS_USER=activemq])
    end

    it "should generate a valid wrapper.conf" do
      should contain_file('wrapper.conf')
      content = catalogue.resource('file', 'wrapper.conf').send(:parameters)[:content]
      content.should match(%r[ACTIVEMQ_HOME=/opt/activemq])
      content.should match(%r[ACTIVEMQ_BASE=/opt/activemq])
      content.should match(%r[wrapper.java.maxmemory=1024])
    end

    it { should_not contain_augeas('activemq-console') }
  end

  context "when using custom home" do
    let(:params) { {
      :home => '/usr/local'
    } }
    it 'should generate valid init.d' do
      should contain_file("/etc/init.d/activemq")
      content = catalogue.resource('file', '/etc/init.d/activemq').send(:parameters)[:content]
      content.should match(%r[ACTIVEMQ_HOME="/usr/local/activemq"])
      content.should match(%r[WRAPPER_CMD="/usr/local/activemq/bin/linux-x86-64/wrapper"])
      content.should match(%r[WRAPPER_CONF="/usr/local/activemq/bin/linux-x86-64/wrapper.conf"])
      content.should match(%r[RUN_AS_USER=activemq])
    end

    it "should generate a valid wrapper.conf" do
      should contain_file('wrapper.conf')
      content = catalogue.resource('file', 'wrapper.conf').send(:parameters)[:content]
      content.should match(%r[ACTIVEMQ_HOME=/usr/local/activemq])
      content.should match(%r[ACTIVEMQ_BASE=/usr/local/activemq])
    end
  end

  context "when using custom memory setting" do
    let(:params) { {
      :max_memory => '256'
    } }

    it "should generate a valid wrapper.conf" do
      should contain_file('wrapper.conf')
      content = catalogue.resource('file', 'wrapper.conf').send(:parameters)[:content]
      content.should match(%r[wrapper.java.maxmemory=256])
    end
  end

  context "when disabling the console" do
    let(:params) { {
      :console => false
    } }

    it { should contain_augeas('activemq-console').with_changes(%r[rm beans/import]) }
  end

end

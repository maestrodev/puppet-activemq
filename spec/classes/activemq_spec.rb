require "#{File.join(File.dirname(__FILE__),'..','spec_helper')}"

describe 'activemq' do
  let(:title) { 'maven' }
  let(:params) { { :user => 'myuser' } }

  context "when using default parameters" do
    it { should contain_service('activemq').with_ensure('running') }
  end

end

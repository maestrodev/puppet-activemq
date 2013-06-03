# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "CentOS-6.4-x86_64-minimal"
  config.vm.network :forwarded_port, guest: 8161, host: 19000
  config.vm.network :forwarded_port, guest: 61613, host: 19001

  config.vm.synced_folder ".", "/etc/puppet/modules/activemq"
  config.vm.synced_folder "spec/fixtures/modules/wget", "/etc/puppet/modules/wget"

  # install the epel module needed for rvm in CentOS
  config.vm.provision :shell, :inline => "test -d /etc/puppet/modules/java || puppet module install puppetlabs/java -v 0.3.0"

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "spec/manifests"
    puppet.manifest_file  = "site.pp"
  end
end

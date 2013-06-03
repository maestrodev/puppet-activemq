# Copyright 2011 MaestroDev
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This activemq class is currently targeting an X86_64 deploy, adjust as needed

class activemq($apache_mirror = "http://archive.apache.org/dist/",
               $version = "5.8.0",
               $home = "/opt",
               $user = "activemq",
               $group = "activemq",
               $system_user = true,
               $max_memory = "1024",
               $console = true) {

  # wget from https://github.com/maestrodev/puppet-wget
  include wget

  if ! defined (User[$user]) {
    user { $user:
      ensure     => present,
      home       => "$home/$user",
      managehome => false,
      system     => $system_user,
    }
  }

  if ! defined (Group[$group]) {
    group { $group:
      ensure  => present,
      system  => $system_user,
      require => User[$user],
    }
  }
  # path flag for the activemq init script template
  case $architecture {
    'x86_64','amd64': {
      $architecture_flag = '64'
    }
    'i386': {
      $architecture_flag = '32'
    }
    default: { fail("Unsupported architecture ${architecture}") }
  }

  wget::fetch { "activemq_download":
    source => "$apache_mirror/activemq/apache-activemq/$version/apache-activemq-${version}-bin.tar.gz",
    destination => "/usr/local/src/apache-activemq-${version}-bin.tar.gz",
    require => [User[$user],Group[$group]],
  } ->
  exec { "activemq_untar":
    command => "tar xf /usr/local/src/apache-activemq-${version}-bin.tar.gz && chown -R $user:$group $home/apache-activemq-$version",
    cwd     => "$home",
    creates => "$home/apache-activemq-$version",
    path    => ["/bin",],
  } ->
  file { "$home/activemq":
    owner  => $user,
    group  => $group,
    ensure  => "$home/apache-activemq-$version",
    require => Exec["activemq_untar"],
  } ->
  file { "/etc/activemq":
    ensure  => "$home/activemq/conf",
    require => File["$home/activemq"],
  } ->
  file { "/var/log/activemq":
    ensure  => "$home/activemq/data",
    require => File["$home/activemq"],
  } ->
  file { "$home/activemq/bin/linux":
    ensure  => "$home/activemq/bin/linux-x86-64",
    require => File["$home/activemq"],
  } ->
  file { "/var/run/activemq":
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => 755,
    require => [User[$user],Group[$group]],
  } ->
  file { "/etc/init.d/activemq":
    owner   => root,
    group   => root,
    mode    => 755,
    content => template("activemq/activemq-init.d.erb"),
  }

  if ! $console {
    augeas { 'activemq-console':
      changes => [
        'rm beans/import',
      ],
      incl    => "${activemq::home}/activemq/conf/activemq.xml",
      lens    => 'Xml.lns',
      require => File["${activemq::home}/activemq"],
      notify  => Service['activemq'],
    }
  }

  case $architecture {
    'x86_64','amd64': {
      file { "wrapper.conf":
        path    => "$home/apache-activemq-$version/bin/linux-x86-64/wrapper.conf",
        owner   => $user,
        group   => $group,
        mode    => 644,
        content => template("activemq/wrapper.conf.erb"),
        require => [File["$home/activemq"],File["/etc/init.d/activemq"]],
        notify  => Service["activemq"],
      }
    }
    'i386': {
      file { "wrapper.conf":
        path    => "$home/apache-activemq-$version/bin/linux-x86-32/wrapper.conf",
        owner   => $user,
        group   => $group,
        mode    => 644,
        content => template("activemq/wrapper.conf.erb"),
        require => [File["$home/activemq"],File["/etc/init.d/activemq"]],
        notify  => Service["activemq"],
      }
    }
  }

  service { "activemq":
    name => "activemq",
    ensure => running,
    hasrestart => true,
    hasstatus => false,
    enable => true,
    require => [User["$user"],Group["$group"]],
  }

}

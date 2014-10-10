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

class activemq (
  $apache_mirror      = "http://archive.apache.org/dist/activemq/",
  $version            = undef,
  $home               = "/opt",
  $user               = "activemq",
  $group              = "activemq",
  $system_user        = true,
  $manage_user        = true,
  $manage_group       = true,
  $max_memory         = "512M",
  $console            = true,
  $package_type       = "tarball",
  $data_dir           = "/var/lib/activemq",
  $tmp_dir            = "/var/tmp/activemq",
  $java_bin           = "",
  $max_shutdown_wait  = "90",
  $activemqxml_source = undef,
  $activemqxml_parameters = undef,
) {

  validate_re($package_type, '^rpm$|^tarball$')
  validate_re($max_memory, '^[0-9][0-9]*[GM]$')
  validate_re($max_shutdown_wait, '^[0-9][0-9]*$')

  if $activemqxml_source and (!$console or defined(Class['activemq::stomp'])) {
    fail('If you set activemqxml_source, console needs to be true and activemq::stomp must not be defined.')
  }

  if $activemqxml_source {
    file { "${activemq::home}/activemq/conf/activemq.xml":
      ensure  =>  present,
      owner   =>  $user,
      group   =>  $group,
      content => template("activemq/activemq-leveldb.xml.erb"),
      require => Anchor["activemq::package::end"],
      notify  => Service["activemq"], 
    }
  }

  case $package_type {
    'tarball': {
      anchor { 'activemq::package::begin': } -> Class['activemq::package::tarball'] -> anchor { 'activemq::package::end': }
      class { 'activemq::package::tarball':
        version => $version,
      }
    }
    'rpm': {
      anchor { 'activemq::package::begin': } -> Class['activemq::package::rpm'] -> anchor { 'activemq::package::end': }
      class { 'activemq::package::rpm':
        version => $version,
      }
    }
    default: {
      fail("Invalid ActiveMQ package type: ${package_type}")
    }
  }

  if ! $console {
    augeas { 'activemq-console':
      changes => [ 'rm beans/import' ],
      incl    => "${activemq::home}/activemq/conf/activemq.xml",
      lens    => 'Xml.lns',
      require => Anchor['activemq::package::end'],
      notify  => Service['activemq'],
    }
  }

  service { 'activemq':
    ensure     => running,
    name       => 'activemq',
    hasrestart => true,
    hasstatus  => true,
    enable     => true,
    require    => Anchor['activemq::package::end'],
  }

}

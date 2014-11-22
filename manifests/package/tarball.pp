class activemq::package::tarball (
  $apache_mirror      = $activemq::apache_mirror,
  $version            = $activemq::version,
  $home               = $activemq::home,
  $user               = $activemq::user,
  $group              = $activemq::group,
  $system_user        = $activemq::system_user,
  $manage_user        = $activemq::manage_user,
  $manage_group       = $activemq::manage_group,
  $max_memory         = $activemq::max_memory,
  $console            = $activemq::console,
  $package_type       = $activemq::package_type,
  $data_dir           = $activemq::data_dir,
  $tmp_dir            = $activemq::tmp_dir,
  $java_bin           = $activemq::java_bin,
  $max_shutdown_wait  = $activemq::max_shutdown_wait,
  $activemqxml_source = $activemq::activemqxml_source,
  $admin_user         = $activemq::admin_user,
  $admin_password     = $activemq::admin_user,
) {

  # wget from https://github.com/maestrodev/puppet-wget
  include wget

  case $::osfamily {
    'Debian': {
      $defaults_file = '/etc/default/activemq'
    }
    default: {
      $defaults_file = '/etc/sysconfig/activemq'
    }
  }

  if $manage_user {
    if ! defined (User[$user]) {
      user { $user:
        ensure     => present,
        home       => "${home}/${user}",
        managehome => false,
        system     => $system_user,
        uid        => 3001,
        before     => Wget::Fetch['activemq_download'],
      }
    }
  }

  if $manage_group {
    if ! defined (Group[$group]) {
      group { $group:
        ensure  => present,
        system  => $system_user,
        gid     => 3001,
        before  => Wget::Fetch['activemq_download'],
      }
    }
  }

  wget::fetch { 'activemq_download':
    source      => "${activemq::apache_mirror}/${version}/apache-activemq-${version}-bin.tar.gz",
    destination => "/usr/local/src/activemq/apache-activemq-${version}-bin.tar.gz",
    cache_dir   => "/usr/local/src/activemq/",
    maintain_cache_dir => true,
  } ->
  exec { 'activemq_untar':
    command => "tar xf /usr/local/src/activemq/apache-activemq-${version}-bin.tar.gz && chown -R ${user}:${group} ${home}/apache-activemq-${version}",
    cwd     => $home,
    creates => "${home}/apache-activemq-${version}",
    path    => ['/bin'],
    before  => File["${home}/activemq"],
  }

  file { "${home}/activemq":
    ensure  => "${home}/apache-activemq-${version}",
    owner   => $user,
    group   => $group,
    require => Exec['activemq_untar'],
  } ->
  file { '/etc/activemq':
    ensure  => "${home}/activemq/conf",
    require => File["${home}/activemq"],
  } ->
  file { '/var/log/activemq':
    ensure  => "${home}/activemq/data",
    require => File["${home}/activemq"],
  } ->
  file { '/var/run/activemq':
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => '0755',
  } ->
  file { $tmp_dir:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => '0755',
  } ->
  file { $data_dir:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => '0755',
  } ->
  file {'/etc/init.d/activemq':
      ensure => 'link',
      source => 'puppet:///modules/activemq/activemq',
      force  => true,
      owner  => root,
      group  => root,
      purge  => true,
  } ->
  file { "${defaults_file}":
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    content => template('activemq/activemq-init-default.erb'),
  }
}

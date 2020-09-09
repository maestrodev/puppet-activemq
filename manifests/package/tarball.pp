class activemq::package::tarball (
  $version      = '5.8.0',
  $home         = $activemq::home,
  $user         = $activemq::user,
  $group        = $activemq::group,
  $system_user  = $activemq::system_user,
  $manage_user  = $activemq::manage_user,
  $manage_group = $activemq::manage_group,
  $enable_jmx          = $activemq::enable_jmx,
  $set_java_initmemory = $activemq::set_java_initmemory,
  $java_initmemory     = $activemq::java_initmemory,
  $java_maxmemory      = $activemq::java_maxmemory,
) {

  # wget from https://github.com/maestrodev/puppet-wget
  include wget

  if $manage_user {
    if ! defined (User[$user]) {
      user { $user:
        ensure     => present,
        home       => "${home}/${user}",
        managehome => false,
        system     => $system_user,
        before     => Wget::Fetch['activemq_download'],
      }
    }
  }

  if $manage_group {
    if ! defined (Group[$group]) {
      group { $group:
        ensure  => present,
        system  => $system_user,
        before  => Wget::Fetch['activemq_download'],
      }
    }
  }

  wget::fetch { 'activemq_download':
    source      => "${activemq::apache_mirror}/activemq/apache-activemq/${version}/apache-activemq-${version}-bin.tar.gz",
    destination => "/usr/local/src/apache-activemq-${version}-bin.tar.gz",
  } ->
  exec { 'activemq_untar':
    command => "tar xf /usr/local/src/apache-activemq-${version}-bin.tar.gz && chown -R ${user}:${group} ${home}/apache-activemq-${version}",
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
  file { "${home}/activemq/bin/linux":
    ensure  => "${home}/activemq/bin/linux-x86-64",
    require => File["${home}/activemq"],
  } ->
  file { '/var/run/activemq':
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => '0755',
  } ->
  file { '/etc/init.d/activemq':
    owner   => root,
    group   => root,
    mode    => '0755',
    content => template('activemq/activemq-init.d.erb'),
  }

  file { 'wrapper.conf':
    path    => $activemq::wrapper,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template('activemq/wrapper.conf.erb'),
    require => [File["${home}/activemq"],File['/etc/init.d/activemq']],
    notify  => Service['activemq'],
  }

  file { 'activemq.xml':
    path    => $activemq::activemqxml,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template('activemq/activemq.xml.erb'),
    require => [File["${home}/activemq"],File['/etc/init.d/activemq']],
    notify  => Service['activemq'],
  }
}

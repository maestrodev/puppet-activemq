class activemq {
  
  user { "$activemq_user":
    ensure     => present,
    home       => "$activemq_home/$activemq_user",
    managehome => false,
    shell      => "/bin/false",
  } ->
  group { "$activemq_group":
    ensure  => present,
    require => User["$activemq_user"],
  } ->
  exec { "activemq_download":
    command => "wget http://mirror.cc.columbia.edu/pub/software/apache//activemq/apache-activemq/$activemq_version/apache-activemq-${activemq_version}-bin.tar.gz",
    cwd     => "/usr/local/src",
    creates => "/usr/local/src/apache-activemq-${activemq_version}-bin.tar.gz",
    path    => ["/usr/bin", "/usr/sbin"],
    require => [Group["$activemq_group"],Package["java-1.6.0-openjdk-devel"]],
  } ->
  exec { "activemq_untar":
    command => "tar xf /usr/local/src/apache-activemq-${activemq_version}-bin.tar.gz && chown -R $activemq_user:$activemq_group $activemq_home/apache-activemq-$activemq_version",
    cwd     => "$activemq_home",
    creates => "$activemq_home/apache-activemq-$activemq_version",
    path    => ["/bin",],
    require => Exec["activemq_download"],
#also need to chown activemq:activemq this dir
  } ->
  file { "$activemq_home/activemq":
    ensure  => "$activemq_home/apache-activemq-5.5.0",
    require => Exec["activemq_untar"],
  } ->
  file { "/etc/activemq":
    ensure  => "$activemq_home/activemq/conf",
    require => File["$activemq_home/activemq"],
  } ->
  file { "/var/log/activemq":
    ensure  => "$activemq_home/activemq/data",
    require => File["$activemq_home/activemq"],
  } ->
  file { "$activemq_home/activemq/bin/linux":
    ensure  => "$activemq_home/activemq/bin/linux-x86-64ac  ",
    require => File["$activemq_home/activemq"],
  } ->
  file { "/var/run/activemq":
    ensure  => directory,
    owner   => activemq,
    group   => activemq,
    mode    => 755,
    require => Group["activemq"],
  } ->
  file { "/etc/init.d/activemq":
    owner   => root,
    group   => root,
    mode    => 755,
    content => template("activemq/activemq-init.d.erb"),
  } ->
  file { "$activemq_home/apache-activemq-$activemq_version/bin/linux-x86-64/wrapper.conf":
    owner   => activemq,
    group   => activemq,
    mode    => 644,
    source  => "puppet://${servername}/modules/activemq/wrapper.conf",
    require => File["$activemq_home/activemq"],
  } ->
  file { "/etc/activemq/activemq.xml":
    owner   => activemq,
    group   => activemq,
    mode    => 644,
    source  => "puppet://${servername}/modules/activemq/activemq.xml",
    require => File["/etc/activemq"]
  } ->
  service { "activemq":
    ensure => running,
    enable => true,
  }
  
}

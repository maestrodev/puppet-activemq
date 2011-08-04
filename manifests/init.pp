class activemq {
  
  user { "activemq":
    ensure     => present,
    home       => "/opt/activemq",
    managehome => false,
    shell      => "/bin/false",
  } ->
  group { "activemq":
    ensure  => present,
    require => User["activemq"],
  } ->
  exec { "activemq_download":
    command => "wget http://mirror.cc.columbia.edu/pub/software/apache//activemq/apache-activemq/5.5.0/apache-activemq-5.5.0-bin.tar.gz",
    cwd     => "/usr/local/src",
    creates => "/usr/local/src/apache-activemq-5.5.0-bin.tar.gz",
    path    => ["/usr/bin", "/usr/sbin"],
    require => [Group["activemq"],Package["java-1.6.0-openjdk-devel"]],
  } ->
  exec { "activemq_untar":
    command => "tar xf /usr/local/src/apache-activemq-5.5.0-bin.tar.gz && chown -R activemq:activemq /opt/apache-activemq-5.5.0",
    cwd     => "/opt",
    creates => "/opt/apache-activemq-5.5.0",
    path    => ["/bin",],
    require => Exec["activemq_download"],
#also need to chown activemq:activemq this dir
  } ->
  file { "/opt/activemq":
    ensure  => "/opt/apache-activemq-5.5.0",
    require => Exec["activemq_untar"],
  } ->
  file { "/etc/activemq":
    ensure  => "/opt/activemq/conf",
    require => File["/opt/activemq"],
  } ->
  file { "/var/log/activemq":
    ensure  => "/opt/activemq/data",
    require => File["/opt/activemq"],
  } ->
  file { "/opt/activemq/bin/linux":
    ensure  => "/opt/activemq/bin/linux-x86-64ac  ",
    require => File["/opt/activemq"],
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
  file { "/opt/apache-activemq-5.5.0/bin/linux-x86-64/wrapper.conf":
    owner   => activemq,
    group   => activemq,
    mode    => 644,
    source  => "puppet://${servername}/modules/activemq/wrapper.conf",
    require => File["/opt/activemq"],
  } ->
  file { "/etc/activemq/activemq.xml":
    owner   => activemq,
    group   => activemq,
    mode    => 644,
    source  => "puppet://${servername}/modules/activemq/activemq.xml",
    require => File["/etc/activemq"]
  } ->
  exec { "activemq":
    command => "/etc/init.d/activemq start",    
   # require    => [File["/etc/init.d/activemq"],File["/var/run/activemq"],File["/etc/activemq/activemq.xml"],File["/opt/apache-activemq-5.5.0/bin/linux-x86-64/wrapper.conf"]],
  }
  
}

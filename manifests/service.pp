class activemq::service (
) inherits activemq::params {

  service { 'activemq':
    ensure     => running,
    name       => 'activemq',
    hasrestart => true,
    hasstatus  => false,
    enable     => true,
    require    => Anchor['activemq::package::end'],
  }
}

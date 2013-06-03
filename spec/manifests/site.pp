class { 'java':
  distribution => 'jre',
} ->
class { 'activemq': }
class { 'activemq::stomp': }

service { 'iptables':
  ensure => stopped,
}

# puppet-activemq

## Overview
This is a simple puppet module for deploying a basic ActiveMQ server

### Basic usage
Get the module to your modules/ subdirectory.

Then add this to a manifest:

```ruby
class { 'activemq':
  version => '5.5.0',
  user    => 'bob',
  group   => 'bob',
  home    => '/opt',
  console => true,
}
```

### Enabling STOMP connector

```puppet
class { 'activemq::stomp':
  port => 61613,
}
```

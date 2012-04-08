# puppet-activemq

## Overview
This is a simple puppet module for deploying a basic ActiveMQ server

### To Use
Get the module to your modules/ subdirectory.

Then add this to a manifest:

```ruby
class { 'activemq':
  version => '5.5.0',
  user    => 'bob',
  group   => 'bob',
  home    => '/opt' 
}
```

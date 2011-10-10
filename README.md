# puppet-activemq

## Overview
This is a simple puppet module for deploying a basic ActiveMQ server

### To Use
Get the module to your modules/ subdirectory.  Ensure you have a proper JDK specified.

```ruby
$jdk_package = "java-1.6.0-openjdk-devel"
```

Then add this to a manifest:

```ruby
class { "activemq": 
  jdk_package => $jdk_package,
  version => "5.5.0",
  user => "bob",
  group => "bob",
  home => "/opt" 
}
```
# puppet-activemq

## Overview
This is a simple puppet module for deploying an Apache ActiveMQ server

### Basic usage
Get the module to your modules/ subdirectory.

Then add this to a manifest:

    class { 'activemq':
      version => '5.6.0',
      user    => 'bob',
      group   => 'bob',
      home    => '/opt',
      console => true,
    }

### Enabling STOMP connector

    class { 'activemq::stomp':
      port => 61613,
    }

# License

    Copyright 2012 MaestroDev

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

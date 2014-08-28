Logasm
================

## Prerequisites
Following software should be installed  & running in your system:

1. Elasticsearch
2. Logstash

[Setup Elasticsearch, Logstash and Kibana](https://github.com/salemove/logasm/blob/master/doc/setup_elasticsearch_logstash_kibana.md)

## Usage

### Creating a new Logasm logger in Ruby

```ruby
Logasm.new(logger_config, application_name)
```

<b>logger_config</b> should contain different logger types and their configuration in json format.

<b>application_name</b> is the name of the application and it will be appended to the json message.

#### Configuration

```
loggers:
  file:
    level: 'debug'
  logstash:
    level: 'info'
    host: 'localhost'
    port: 5228
```
Level can be:

1. unknown
2. fatal
3. error
4. warn
5. info - default for logstash
6. debug - default for file

For example level: 'warn' will log everything with warn and above.

#### Examples

Creating a new file logger

```ruby
require 'logasm'

logasm = Logasm.new({:file=>nil},'myApp')
```

Creating a new logstash logger

```ruby
require 'logasm'

logasm = Logasm.new({:logstash=>{:host=>"localhost", :port=>5228}},'myApp')
```

Creating a new logger that logs into file and logstash at the same time

```ruby
require 'logasm'

logasm = Logasm.new({:file=>nil, :logstash=>{:host=>"localhost", :port=>5228}},'myApp')
```

When no loggers are specified, it creates a file logger by default.

### Creating a new Logasm logger in Node.js

```coffee
require('logasm')(logger_config, "application_name")
```
<b>logger_config</b> should contain different logger types and their configuration in json format.

<b>application_name</b> is the name of the application and it will be appended to the json message.

#### Configuration

```
"loggers": {
  "file": {
    "level": "debug"
  },
  "logstash": {
    "port": 5228,
    "host": "127.0.0.1",
    "level": "warn"
  }
}
```
Level can be:

1. error
2. warn
3. info - default for logstash
4. verbose
5. debug - default for file

For example "level": "warn" will log everything with warn and above.

#### Examples

Creating a new file logger

```coffee
logasm = require('logasm')({ file: {} })
```

Creating a new logstash logger

```coffee
logasm = require('logasm')({logstash: {port: 5228, host: "127.0.0.1"}})
```

Creating a new logger that logs into file and logstash at the same time

```coffee
logasm = require('logasm')({file: {}, logstash: {port: 5228, host: "127.0.0.1"}})
```

When no loggers are specified, it creates a file logger by default.

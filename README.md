Logasm
================

## Prerequisites
Following software should be installed  & running in your system:

1. Elasticsearch
2. Logstash

## Usage

### Creating a new Logasm logger in Ruby

```ruby
Logasm.new(logger_config, application_name)
```

<b>logger_config</b> should contain different logger types and their configuration in json format.

<b>application_name</b> is the name of the application and it will be appended to the json message.

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

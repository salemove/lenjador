Logasm
================

## Usage

### Creating a new Logasm logger in Ruby

```ruby
Logasm.new(application_name, logger_config)
```

<b>application_name</b> is the name of the application and it will be appended to the json message.

<b>logger_config</b> should contain different logger types and their configuration in json format.

#### Configuration

```
loggers:
  stdout:
    level: 'debug'
  logstash:
    level: 'info'
    host: 'localhost'
    port: 5228
```
Supported log levels:

1. fatal
2. error
3. warn
4. info
5. debug

For example level: 'warn' will log everything with warn and above.

#### Examples

Creating a new stdout logger

```ruby
require 'logasm'

logasm = Logasm.build('myApp', stdout: nil)
```

Creating a new logstash logger

```ruby
require 'logasm'

logasm = Logasm.build('myApp', logstash: {host: "localhost", port: 5228})
```

Creating a new logger that logs into stdout and logstash at the same time

```ruby
require 'logasm'

logasm = Logasm.new('myApp', { stdout: nil, logstash: {:host=>"localhost", :port=>5228} })
```

When no loggers are specified, it creates a stdout logger by default.

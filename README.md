Lenjador
================

## Usage

### Creating a new Lenjador logger in Ruby

```ruby
Lenjador.build(application_name, logger_config)
```

<b>logger_config</b> is a hash with logger types and their configuration.

#### Configuration

```
loggers:
  stdout:
    level: 'debug'
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
require 'lenjador'

lenjador = Lenjador.build('myApp', stdout: nil)
```

When no loggers are specified, it creates a stdout logger by default.

## Preprocessors

Preprocessors allow modification of log messages, prior to sending of the message to the configured logger(s).

### Blacklist

Excludes or masks defined fields of the passed hash object.
You can specify the name of the field and which action to take on it.
Nested hashes of any level are preprocessed as well.

Available actions:

* `prune` (default) - fully excludes the field and its value from the hash.
* `mask` - replaces every character from the original value with `*`. 
  In case of `array`, `hash` or `boolean` value is replaced with one `*`.

#### Configuration

```yaml
preprocessors:
  blacklist:
    fields:
      - key: password
      - key: phone
    action: mask
```

#### Usage

```ruby
logger = Lenjador.build(application_name, logger_config, preprocessors)

input = {password: 'password', info: {phone: '+12055555555'}}

logger.debug("Received request", input)
```

Logger output:

```
Received request {"info":{"phone":"************"}}
```

### Whitelist

Prunes or masks all the fields except those whitelisted in the configuration using [JSON Pointer](https://tools.ietf.org/html/rfc6901).
Only simple values(`string`, `number`, `boolean`) can be whitelisted.
Whitelisting array and hash elements can be done using wildcard symbol `~`.

Available actions:

* `mask` (default) - replaces every character from the original value with `*`. 
  In case of `array`, `hash` or `boolean` value is replaced with one `*`.
* `prune` - fully excludes the field and its value from the hash.

#### Configuration

```yaml
preprocessors:
  whitelist:
    pointers: ['/info/phone', '/addresses/~/host']
  action: prune
```

#### Usage

```ruby
logger = Lenjador.build(application_name, logger_config, preprocessors)

input = {password: 'password', info: {phone: '+12055555555'}, addresses: [{host: 'example.com', path: 'info'}]}

logger.debug("Received request", input)
```

Logger output:

```
Received request {password: "********", "info": {"phone": "+12055555555"}, "addresses": [{"host": "example.com","path": "****"}]}
```

var events = require('events'),
    util = require('util'),
    cycle = require('cycle'),
    winston = require('winston'),
    common = require('winston/lib/winston/common');

var LogasmConsole = exports.LogasmConsole = function (options) {
  winston.Transport.call(this, options);
  options = options || {};

  this.json        = options.json        || false;
  this.colorize    = options.colorize    || false;
  this.prettyPrint = options.prettyPrint || false;
  this.timestamp   = typeof options.timestamp !== 'undefined' ? options.timestamp : false;
  this.label       = options.label       || null;
  this.logstash    = options.logstash    || false;

  if (this.json) {
    this.stringify = options.stringify || function (obj) {
      return JSON.stringify(obj, null, 2);
    };
  }
};

util.inherits(LogasmConsole, winston.Transport);

winston.transports.LogasmConsole = LogasmConsole;

LogasmConsole.prototype.name = 'logasmConsole';

LogasmConsole.prototype.log = function (level, msg, meta, callback) {
  if (this.silent) {
    return callback(null, true);
  }

  var self = this,
      output;

  output = self.format_log({
    colorize:    this.colorize,
    json:        this.json,
    level:       level,
    message:     msg,
    meta:        meta,
    stringify:   this.stringify,
    timestamp:   this.timestamp,
    prettyPrint: this.prettyPrint,
    raw:         this.raw,
    label:       this.label,
    logstash:    this.logstash
  });

  if (level === 'error' || level === 'debug') {
    process.stderr.write(output + '\n');
  } else {
    process.stdout.write(output + '\n');
  }

  self.emit('logged');
  callback(null, true);
};

LogasmConsole.prototype.format_log = function (options) {
  var timestampFn = typeof options.timestamp === 'function'
                  ? options.timestamp
                  : common.timestamp,
      timestamp   = options.timestamp ? timestampFn() : null,
      meta        = options.meta !== undefined || options.meta !== null ? common.clone(cycle.decycle(options.meta)) : null,
      output;

  //
  // raw mode is intended for outputing winston as streaming JSON to STDOUT
  //
  if (options.raw) {
    if (typeof meta !== 'object' && meta != null) {
      meta = { meta: meta };
    }
    output         = common.clone(meta) || {};
    output.level   = options.level;
    output.message = options.message.stripColors;
    return JSON.stringify(output);
  }

  //
  // json mode is intended for pretty printing multi-line json to the terminal
  //
  if (options.json || true === options.logstash) {
    if (typeof meta !== 'object' && meta != null) {
      meta = { meta: meta };
    }

    output         = common.clone(meta) || {};
    output.level   = options.level;
    output.message = options.message;
    if (options.label) {
      output.label = options.label;
    }
    if (timestamp) {
      output.timestamp = timestamp;
    }

    if (typeof options.stringify === 'function') {
      return options.stringify(output);
    }

    return JSON.stringify(output, function (key, value) {
      return value instanceof Buffer
        ? value.toString('base64')
        : value;
    });
  }

  output = timestamp ? timestamp + ' - ' : '';
  output += options.colorize ? winston.config.colorize(options.level) : options.level;
  output += ': ';
  output += options.label ? ('[' + options.label + '] ') : '';
  output += options.message;

  if (meta !== null && meta !== undefined) {
    if (meta && meta instanceof Error && meta.stack) {
      meta = meta.stack;
    }

    if (typeof meta !== 'object') {
      output += ' ' + meta;
    }
    else if (Object.keys(meta).length > 0) {
      output += ' ' + (
        options.prettyPrint
          ? ('\n' + util.inspect(meta, false, null, options.colorize))
          : JSON.stringify(meta)
      );
    }
  }

  return output;
};

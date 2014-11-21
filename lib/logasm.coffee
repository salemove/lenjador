module.exports = (loggers, service_name) ->
  winston = require 'winston'
  logasm = new winston.Logger
  logasm.timestamp = ->
    "#{new Date().toISOString()} ##{process.pid}"

  unless loggers
    add_logger "file", {}, service_name, logasm, winston

  for logger, options of loggers
    add_logger logger, options, service_name, logasm, winston

  return logasm

add_logger = (type, args, service_name, logasm, winston) ->
  if type is 'file'
    require "./console_override/logasm_console"

    if typeof args.timestamp is 'undefined'
      timestamp = logasm.timestamp
    else
      timestamp = args.timestamp

    options =
      level: args.level or 'debug'
      colorize: args.colorize or true
      timestamp: timestamp

    logasm.add winston.transports.LogasmConsole, options

  else if type is 'logstash'
    LogasmLogstashUDP = require "./logstash_override/winston-logstash-udp"

    options =
      port: args.port or 5229
      application: service_name or "undefined"
      host: args.host or "127.0.0.1"
      level: args.level or 'info'
      timestamp: logasm.timestamp

    logasm.add LogasmLogstashUDP, options

  else if type is 'loggly'
    # Not implemented
    require 'winston-loggly'

    options =
      level: args.level or "info"
      subdomain: args.subdomain or "smtest2"
      inputToken: args.inputToken or "60264bf2-5e69-4c03-8169-d7334476782e"
      json: args.json or true
      handleExceptions: args.handleExceptions or true
      tags: args.tags or []

module.exports = (loggers, service_name) ->
  winston = require 'winston'
  logasm = new winston.Logger
  logasm.timestamp = ->
    "#{new Date().toISOString()} ##{process.pid}"

  for logger, options of loggers
    add_logger logger, options, service_name, logasm, winston

  return logasm

add_logger = (type, args, service_name, logasm, winston) ->
  if type is 'file'
    options =
      level: args.level or 'info'
      colorize: args.colorize or true
      timestamp: logasm.timestamp

    logasm.add winston.transports.Console, options

  else if type is 'logstash'
    LogasmLogstashUDP = require "./logstash_override/winston-logstash-udp"

    options =
      port: args.port or 5228
      application: service_name or "undefined"
      host: args.host or "127.0.0.1"
      level: args.level or 'info'
      timestamp: logasm.timestamp

    logasm.add LogasmLogstashUDP, options

  else if type is 'loggly'
    console.log 'Loggly is currently not implemented'
    require 'winston-loggly'

    options =
      level: args.level or "info"
      subdomain: args.subdomain or "smtest2"
      inputToken: args.inputToken or "60264bf2-5e69-4c03-8169-d7334476782e"
      json: args.json or true
      handleExceptions: args.handleExceptions or true
      tags: args.tags or []

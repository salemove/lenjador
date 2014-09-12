winston = require('winston');
os = require('os');
log = require("winston-logstash-udp");
util = require("util");
common = require('winston/lib/winston/common');

var LogasmLogstashUDP = function(options) {
    winston.Transport.call(this, options);
    options = options || {};

    this.name = 'logstashUdp';
    this.level = options.level.toLowerCase();
    this.localhost = options.localhost || os.hostname();
    this.host = options.host;
    this.port = options.port;
    this.application = options.application;
    this.pid = options.pid || process.pid;

    this.client = null;

    this.connect();
};

util.inherits(LogasmLogstashUDP, log.LogstashUDP);

module.exports = LogasmLogstashUDP;

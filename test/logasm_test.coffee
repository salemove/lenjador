describe 'Logasm', ->
  it 'creates logger when no options are specified', (done) ->
    logasm = require('../lib/logasm')()

    logasm.transports.should.eql({})
    done()

  it 'creates file logger', (done) ->
    logasm = require('../lib/logasm')({ file: {} })

    logasm.transports.should.not.eql({})
    logasm.transports.console.should.exist
    done()

  it 'creates logstash logger', (done) ->
    logasm = require('../lib/logasm')({ logstash: {} })

    logasm.transports.should.not.eql({})
    logasm.transports.logstashUdp.should.exist
    done()

  it 'creates multiple loggers', (done) ->
    logasm = require('../lib/logasm')({ file: {}, logstash: {} })

    logasm.transports.should.not.eql({})
    logasm.transports.console.should.exist
    logasm.transports.logstashUdp.should.exist
    done()





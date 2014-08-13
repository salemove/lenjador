require 'spec_helper'
require 'sm-logger'

describe SMLogger do
  it 'can create file logger' do
    sm_logger = SMLogger.new({:file=>nil},'test_service')
    number_of_loggers = sm_logger.loggers.count

    expect(number_of_loggers).to eq(1)

    logdev = sm_logger.loggers[0].instance_variable_get(:@logdev)

    expect(logdev).to be_a Logger::LogDevice
    expect(logdev.instance_variable_get(:@dev)).to be_a IO
  end

  it 'can create logstash logger' do
    sm_logger = SMLogger.new({:logstash=>{:host=>"localhost", :port=>5228}},'test_service')
    number_of_loggers = sm_logger.loggers.count

    expect(number_of_loggers).to eq(1)

    logdev = sm_logger.loggers[0].instance_variable_get(:@logdev)

    expect(logdev).to be_a Logger::LogDevice
    expect(logdev.instance_variable_get(:@dev)).to be_a LogStashLogger::Device::UDP
  end

  it 'can create multiple loggers' do
    sm_logger = SMLogger.new({:file=>nil, :logstash=>{:host=>"localhost", :port=>5228}},'test_service')
    number_of_loggers = sm_logger.loggers.count

    expect(number_of_loggers).to eq(2)

    logdev_file = sm_logger.loggers[0].instance_variable_get(:@logdev)

    expect(logdev_file).to be_a Logger::LogDevice
    expect(logdev_file.instance_variable_get(:@dev)).to be_a IO

    logdev_logstash = sm_logger.loggers[1].instance_variable_get(:@logdev)

    expect(logdev_logstash).to be_a Logger::LogDevice
    expect(logdev_logstash.instance_variable_get(:@dev)).to be_a LogStashLogger::Device::UDP
  end
end

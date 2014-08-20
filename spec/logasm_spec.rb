require 'spec_helper'
require 'logasm'

describe Logasm do
  it 'creates file logger' do
    logasm = Logasm.new({:file=>nil},'test_service')
    number_of_loggers = logasm.loggers.count

    expect(number_of_loggers).to eq(1)

    logdev = logasm.loggers[0].instance_variable_get(:@logdev)

    expect(logdev).to be_a Logger::LogDevice
    expect(logdev.instance_variable_get(:@dev)).to be_a IO
  end

  it 'creates logstash logger' do
    logasm = Logasm.new({:logstash=>{:host=>"localhost", :port=>5228}},'test_service')
    number_of_loggers = logasm.loggers.count

    expect(number_of_loggers).to eq(1)

    logdev = logasm.loggers[0].instance_variable_get(:@logdev)

    expect(logdev).to be_a Logger::LogDevice
    expect(logdev.instance_variable_get(:@dev)).to be_a LogStashLogger::Device::UDP
  end

  it 'creates multiple loggers' do
    logasm = Logasm.new({:file=>nil, :logstash=>{:host=>"localhost", :port=>5228}},'test_service')
    number_of_loggers = logasm.loggers.count

    expect(number_of_loggers).to eq(2)

    logdev_file = logasm.loggers[0].instance_variable_get(:@logdev)

    expect(logdev_file).to be_a Logger::LogDevice
    expect(logdev_file.instance_variable_get(:@dev)).to be_a IO

    logdev_logstash = logasm.loggers[1].instance_variable_get(:@logdev)

    expect(logdev_logstash).to be_a Logger::LogDevice
    expect(logdev_logstash.instance_variable_get(:@dev)).to be_a LogStashLogger::Device::UDP
  end

  it 'creates file logger when no loggers are specified' do
    logasm = Logasm.new(nil,'test_service')
    number_of_loggers = logasm.loggers.count

    expect(number_of_loggers).to eq(1)

    logdev = logasm.loggers[0].instance_variable_get(:@logdev)

    expect(logdev).to be_a Logger::LogDevice
    expect(logdev.instance_variable_get(:@dev)).to be_a IO
  end
end

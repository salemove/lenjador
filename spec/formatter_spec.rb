require 'spec_helper'
require 'logasm'
require 'logstash-logger/formatter'

module LogStashLogger
  describe Formatter do
    let!(:formatter) { Formatter.new('test_service') }

    it 'message should have application name' do
      json = get_event_json 'test_message'

      expect(json['application']).to eq('test_service')
    end

    it 'converts severity to level' do
      json = get_event_json 'test_message'

      expect(json['level']).to eq("debug")
      expect(json['severity']).to eq(nil)
    end

    def get_event_json(message)
      response = formatter.call('debug', "2014-09-11 14:55:00 +0300", nil, message)
      JSON.parse(response)
    end
  end
end

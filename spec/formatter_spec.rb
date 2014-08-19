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

    it 'adds message when no json is found' do
      json = get_event_json 'test_message'

      expect(json['message']).to eq('test_message')
    end

    it 'can parse json' do
      json = get_event_json '{"not_message":"test_message","leet":1337}'

      expect(json['message']).to eq(nil)
      expect(json['not_message']).to eq('test_message')
      expect(json['leet']).to eq(1337)
    end

    it 'can parse json from text' do
      json = get_event_json 'hi {"not_message":"test_message","leet":1337} lol'

      expect(json['message']).to eq(nil)
      expect(json['not_message']).to eq('test_message')
      expect(json['leet']).to eq(1337)
    end

    it 'adds unparsed message if there is json' do
      json = get_event_json 'hi {"not_message":"test_message","leet":1337} lol'

      expect(json['unparsed']).to eq('hi {*parsed*} lol')
    end

    def get_event_json(message)
      response = formatter.call('debug', 0, nil, message)
      JSON.parse(response)
    end
  end
end

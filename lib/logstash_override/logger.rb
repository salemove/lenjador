module LogStashLogger
  def self.new(service_name, opts = {})
    @device = Device.new(opts)

    ::Logger.new(@device).tap do |logger|
      logger.extend(self)
      logger.extend(TaggedLogging)
      logger.formatter = Formatter.new(service_name)
    end
  end
end

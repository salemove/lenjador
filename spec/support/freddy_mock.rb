class FreddyMock
  attr_reader :deliveries

  def initialize
    @deliveries = []
  end

  def deliver(queue, params)
    @deliveries << [queue, params]
  end
end

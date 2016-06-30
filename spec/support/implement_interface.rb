RSpec::Matchers.define :implement_interface do |expected|
  required_methods = expected.instance_methods(false)
  match do |actual|
    required_methods - actual.methods == []
  end

  failure_message do |actual|
    missing_methods = required_methods - actual.methods
    "Expected instance methods #{missing_methods.inspect} to be implemented"
  end
end

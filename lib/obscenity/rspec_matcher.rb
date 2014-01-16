if defined?(RSpec::Matchers)
  require 'rspec/expectations'

  RSpec::Matchers.define :be_profane do |expected|
    match do |actual|
      Obscenity.profane?(actual) == expected
    end
  end
end

if defined?(RSpec::Matchers)
  RSpec::Matchers.define :be_profane do |expected|
    match do |actual|
      Obscenity.profane?(actual) == expected
    end
  end
end

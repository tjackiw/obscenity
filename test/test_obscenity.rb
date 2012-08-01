require 'helper'

class TestObscenity < Test::Unit::TestCase

  context "#respond_to?" do
    should "respond to methods and attributes" do
      [:configure, :config, :profane?, :sanitize, :offensive, :replacement].each do |field|
        assert Obscenity.respond_to?(field)
      end
    end
  end

  # More comprehensive test in test_config.rb
  context "#configure" do
    should "accept a configuration block " do
      assert_nothing_raised{
        Obscenity.configure do |config|
          config.blacklist   = :default
          config.replacement = :garbled
        end
      }
    end
  end

  # More comprehensive test in test_config.rb
  context "#config" do
    should "return the current config object" do
      assert_not_nil Obscenity.config
    end
  end

  # More comprehensive test in test_base.rb
  context "#profane?" do
    should "validate the profanity of the given content" do
      assert Obscenity.profane?('Yo, check that ass out')
      assert !Obscenity.profane?('Hello world')
    end
  end

  # More comprehensive test in test_base.rb
  context "#sanitize" do
    should "sanitize the given content" do
      assert_equal "Yo, check that $@!#% out", Obscenity.sanitize('Yo, check that ass out')
      assert_equal "Hello world", Obscenity.sanitize('Hello world')
    end
  end

  # More comprehensive test in test_base.rb
  context "#offensive" do
    should "return the offensive words for the given content" do
      assert_equal ['ass', 'biatch'], Obscenity.offensive('Yo, check that ass biatch')
      assert_equal [], Obscenity.offensive('Hello world')
    end
  end

  # More comprehensive test in test_base.rb
  context "#replacement" do
    should "sanitize the given content based on the given replacement" do
      assert_equal "Yo, check that $@!#% out", Obscenity.replacement(:garbled).sanitize('Yo, check that ass out')
      assert_equal "Yo, check that $@!#% out", Obscenity.replacement(:default).sanitize('Yo, check that ass out')
      assert_equal "Yo, check that *ss out", Obscenity.replacement(:vowels).sanitize('Yo, check that ass out')
      assert_equal "Yo, check that *h*t out", Obscenity.replacement(:nonconsonants).sanitize('Yo, check that 5hit out')
      assert_equal "Yo, check that *** out", Obscenity.replacement(:stars).sanitize('Yo, check that ass out')
      assert_equal "Yo, check that [censored] out", Obscenity.replacement("[censored]").sanitize('Yo, check that ass out')
      assert_equal "Hello world", Obscenity.sanitize('Hello world')
    end
  end

end

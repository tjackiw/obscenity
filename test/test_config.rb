require 'helper'

class TestConfig < Test::Unit::TestCase

  context "#respond_to?" do
    should "respond to methods and attributes" do
      Obscenity::Config.new do |config|
        [:blocklist, :allowlist, :replacement].each do |field|
          assert config.respond_to?(field)
        end
      end
    end
  end

  should "properly set the config parameters" do
    blocklist   = ['ass', 'shit', 'penis']
    allowlist   = ['penis']
    replacement = :stars

    config = Obscenity::Config.new do |config|
      config.blocklist   = blocklist
      config.allowlist   = allowlist
      config.replacement = replacement
    end

    assert_equal blocklist, config.blocklist
    assert_equal allowlist, config.allowlist
    assert_equal replacement, config.replacement
  end

  should "return default values if none is set" do
    config = Obscenity::Config.new
    assert_equal [], config.allowlist
    assert_equal :garbled, config.replacement
    assert_match(/config\/blocklist.yml/, config.blocklist)
  end

  should "return default values when default values are set" do
    config = Obscenity::Config.new do |config|
      config.blocklist   = :default
      config.replacement = :default
    end
    assert_equal [], config.allowlist
    assert_equal :default, config.replacement
    assert_match /config\/blocklist.yml/, config.blocklist
  end

  should "properly validate the config options" do
    [:blocklist, :allowlist].each do |field|
      exceptions = [
        [Obscenity::UnknownContent, {}], 
        [Obscenity::UnknownContent, ":unknown"], 
        [Obscenity::EmptyContentList, []], 
        [Obscenity::UnknownContentFile, "'path/to/file'"], 
        [Obscenity::UnknownContentFile, Pathname.new("'path/to/file'")]
      ].each do |klass, value|
        assert_raise(klass){
          Obscenity::Config.new do |config|
            config.instance_eval "config.#{field} = #{value}"
          end
        }
      end
    end
  end

end

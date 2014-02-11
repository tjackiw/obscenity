require 'helper'

class TestConfig < Test::Unit::TestCase

  context "#respond_to?" do
    should "respond to methods and attributes" do
      Obscenity::Config.new do |config|
        [:blacklist, :whitelist, :replacement, :word_size].each do |field|
          assert config.respond_to?(field)
        end
      end
    end
  end
  
  should "properly set the config parameters" do
    blacklist   = ['ass', 'shit', 'penis']
    whitelist   = ['penis']
    replacement = :stars
    word_size = 3
    
    config = Obscenity::Config.new do |config|
      config.blacklist   = blacklist
      config.whitelist   = whitelist
      config.replacement = replacement
      config.word_size = word_size
    end
    
    assert_equal blacklist, config.blacklist
    assert_equal whitelist, config.whitelist
    assert_equal replacement, config.replacement
    assert_equal word_size, config.word_size
  end

  should "return default values if none is set" do
    config = Obscenity::Config.new
    assert_equal [], config.whitelist
    assert_equal :garbled, config.replacement
    assert_match /config\/blacklist.yml/, config.blacklist
    assert_equal 3, config.word_size
  end

  should "return default values when default values are set" do
    config = Obscenity::Config.new do |config|
      config.blacklist   = :default
      config.replacement = :default
      config.word_size = :default
    end
    assert_equal [], config.whitelist
    assert_equal :default, config.replacement
    assert_equal :default, config.word_size
    assert_match /config\/blacklist.yml/, config.blacklist
  end
  
  should "properly validate the config options" do
    [:blacklist, :whitelist].each do |field|
      exceptions = [
        [Obscenity::UnkownContent, {}], 
        [Obscenity::UnkownContent, ":unkown"], 
        [Obscenity::EmptyContentList, []], 
        [Obscenity::UnkownContentFile, "'path/to/file'"], 
        [Obscenity::UnkownContentFile, Pathname.new("'path/to/file'")]
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

require 'helper'

class TestBase < Test::Unit::TestCase

  context "#respond_to?" do
    should "respond to methods and attributes" do
      [:blacklist, :whitelist, :profane?, :sanitize, :replacement, :offensive, :replace].each do |field|
        assert Obscenity::Base.respond_to?(field)
      end
    end
  end

  context "#blacklist" do
    context "without custom config" do
      setup { Obscenity::Base.blacklist = :default }
      should "use the default content file when no config is found" do
        assert Obscenity::Base.blacklist.is_a?(Array)
        assert_equal 565, Obscenity::Base.blacklist.size
      end
    end
    context "with custom config" do
      setup { Obscenity::Base.blacklist = ['bad', 'word'] }
      should "respect the config options" do
        assert_equal ['bad', 'word'], Obscenity::Base.blacklist
      end
    end
  end

  context "#whitelist" do
    context "without custom config" do
      setup { Obscenity::Base.whitelist = :default }
      should "use the default content file when no config is found" do
        assert Obscenity::Base.whitelist.is_a?(Array)
        assert Obscenity::Base.whitelist.empty?
      end
    end
    context "with custom config" do
      setup { Obscenity::Base.whitelist = ['safe', 'word'] }
      should "respect the config options" do
        assert_equal ['safe', 'word'], Obscenity::Base.whitelist
      end
    end
  end

  context "#profane?" do
    context "without whitelist" do
      context "without custom config" do
        setup {
          Obscenity::Base.blacklist = :default
          Obscenity::Base.whitelist = :default
        }
        should "validate the profanity of a word based on the default list" do
          assert Obscenity::Base.profane?('ass')
          assert Obscenity::Base.profane?('biatch')
          assert !Obscenity::Base.profane?('hello')
        end
      end
      context "with custom blacklist config" do
        setup { Obscenity::Base.blacklist = ['ass', 'word'] }
        should "validate the profanity of a word based on the custom list" do
          assert Obscenity::Base.profane?('ass')
          assert Obscenity::Base.profane?('word')
          assert !Obscenity::Base.profane?('biatch')
        end
      end
    end
    context "with whitelist" do
      context "without custom blacklist config" do
        setup {
          Obscenity::Base.blacklist = :default
          Obscenity::Base.whitelist = ['biatch']
        }
        should "validate the profanity of a word based on the default list" do
          assert Obscenity::Base.profane?('ass')
          assert !Obscenity::Base.profane?('biatch')
          assert !Obscenity::Base.profane?('hello')
        end
      end
      context "with custom blacklist/whitelist config" do
        setup {
          Obscenity::Base.blacklist = ['ass', 'word']
          Obscenity::Base.whitelist = ['word']
        }
        should "validate the profanity of a word based on the custom list" do
          assert Obscenity::Base.profane?('ass')
          assert !Obscenity::Base.profane?('word')
          assert !Obscenity::Base.profane?('biatch')
        end
      end
    end
  end

  context "#sanitize" do
    context "without whitelist" do
      context "without custom config" do
        setup {
          Obscenity::Base.blacklist = :default
          Obscenity::Base.whitelist = :default
        }
        should "sanitize and return a clean text based on the default list" do
          assert_equal "Yo $@!#%, sup", Obscenity::Base.sanitize('Yo assclown, sup')
          assert_equal "Hello world", Obscenity::Base.sanitize('Hello world')
        end
      end
      context "with custom blacklist config" do
        setup { Obscenity::Base.blacklist = ['ass', 'word'] }
        should "sanitize and return a clean text based on a custom list" do
          assert_equal "Yo $@!#%, sup", Obscenity::Base.sanitize('Yo word, sup')
          assert_equal "Hello world", Obscenity::Base.sanitize('Hello world')
        end
      end
    end
    context "with whitelist" do
      context "without custom blacklist config" do
        setup {
          Obscenity::Base.blacklist = :default
          Obscenity::Base.whitelist = ['biatch']
        }
        should "sanitize and return a clean text based on the default blacklist and custom whitelist" do
          assert_equal "Yo $@!#%, sup", Obscenity::Base.sanitize('Yo assclown, sup')
          assert_equal "Yo biatch, sup", Obscenity::Base.sanitize('Yo biatch, sup')
        end
      end
      context "with custom blacklist/whitelist config" do
        setup {
          Obscenity::Base.blacklist = ['clown', 'biatch']
          Obscenity::Base.whitelist = ['biatch']
        }
        should "validate the profanity of a word based on the custom list" do
          assert_equal "Yo $@!#%, sup", Obscenity::Base.sanitize('Yo clown, sup')
          assert_equal "Yo biatch, sup", Obscenity::Base.sanitize('Yo biatch, sup')
        end
      end
    end
  end

  context "#replacement" do
    context "without whitelist" do
      context "without custom config" do
        setup {
          Obscenity::Base.blacklist = :default
          Obscenity::Base.whitelist = :default
        }
        should "sanitize and return a clean text based on the default list" do
          assert_equal "Yo ********, sup", Obscenity::Base.replacement(:stars).sanitize('Yo assclown, sup')
          assert_equal "Yo $@!#%, sup", Obscenity::Base.replacement(:garbled).sanitize('Yo assclown, sup')
          assert_equal "Yo *sscl*wn, sup", Obscenity::Base.replacement(:vowels).sanitize('Yo assclown, sup')
          assert_equal "Oh, *h*t!", Obscenity::Base.replacement(:nonconsonants).sanitize('Oh, 5hit!')
          assert_equal "Yo [censored], sup", Obscenity::Base.replacement('[censored]').sanitize('Yo assclown, sup')
          assert_equal "Hello World", Obscenity::Base.replacement(:default).sanitize('Hello World')
        end
      end
      context "with custom blacklist config" do
        setup { Obscenity::Base.blacklist = ['ass', 'word', 'w0rd'] }
        should "sanitize and return a clean text based on a custom list" do
          assert_equal "Yo ****, sup", Obscenity::Base.replacement(:stars).sanitize('Yo word, sup')
          assert_equal "Yo $@!#%, sup", Obscenity::Base.replacement(:garbled).sanitize('Yo word, sup')
          assert_equal "Yo w*rd, sup", Obscenity::Base.replacement(:vowels).sanitize('Yo word, sup')
          assert_equal "Yo w*rd, sup", Obscenity::Base.replacement(:nonconsonants).sanitize('Yo w0rd, sup')
          assert_equal "Yo [censored], sup", Obscenity::Base.replacement('[censored]').sanitize('Yo word, sup')
          assert_equal "Hello World", Obscenity::Base.replacement(:default).sanitize('Hello World')
        end
      end
    end
    context "with whitelist" do
      context "without custom blacklist config" do
        setup {
          Obscenity::Base.blacklist = :default
          Obscenity::Base.whitelist = ['biatch']
        }
        should "sanitize and return a clean text based on the default blacklist and custom whitelist" do
          assert_equal "Yo ********, sup", Obscenity::Base.replacement(:stars).sanitize('Yo assclown, sup')
          assert_equal "Yo $@!#%, sup", Obscenity::Base.replacement(:garbled).sanitize('Yo assclown, sup')
          assert_equal "Yo *sscl*wn, sup", Obscenity::Base.replacement(:vowels).sanitize('Yo assclown, sup')
          assert_equal "What an *r**", Obscenity::Base.replacement(:nonconsonants).sanitize('What an ar5e')
          assert_equal "Yo [censored], sup", Obscenity::Base.replacement('[censored]').sanitize('Yo assclown, sup')
          assert_equal "Yo biatch, sup", Obscenity::Base.replacement(:default).sanitize('Yo biatch, sup')
        end
      end
      context "with custom blacklist/whitelist config" do
        setup {
          Obscenity::Base.blacklist = ['clown', 'biatch']
          Obscenity::Base.whitelist = ['biatch']
        }
        should "validate the profanity of a word based on the custom list" do
          assert_equal "Yo *****, sup", Obscenity::Base.replacement(:stars).sanitize('Yo clown, sup')
          assert_equal "Yo $@!#%, sup", Obscenity::Base.replacement(:garbled).sanitize('Yo clown, sup')
          assert_equal "Yo cl*wn, sup", Obscenity::Base.replacement(:vowels).sanitize('Yo clown, sup')
          assert_equal "Yo cl*wn, sup", Obscenity::Base.replacement(:nonconsonants).sanitize('Yo clown, sup')
          assert_equal "Yo [censored], sup", Obscenity::Base.replacement('[censored]').sanitize('Yo clown, sup')
          assert_equal "Yo biatch, sup", Obscenity::Base.replacement(:default).sanitize('Yo biatch, sup')
          assert_equal "Yo assclown, sup", Obscenity::Base.replacement(:default).sanitize('Yo assclown, sup')
        end
      end
    end
  end

  context "#offensive" do
    context "without whitelist" do
      context "without custom config" do
        setup {
          Obscenity::Base.blacklist = :default
          Obscenity::Base.whitelist = :default
        }
        should "return an array with the offensive words based on the default list" do
          assert_equal ['assclown'], Obscenity::Base.offensive('Yo assclown, sup')
          assert_equal [], Obscenity::Base.offensive('Hello world')
        end
      end
      context "with custom blacklist config" do
        setup { Obscenity::Base.blacklist = ['yo', 'word'] }
        should "return an array with the offensive words based on a custom list" do
          assert_equal ['yo', 'word'], Obscenity::Base.offensive('Yo word, sup')
          assert_equal [], Obscenity::Base.offensive('Hello world')
        end
      end
    end
    context "with whitelist" do
      context "without custom blacklist config" do
        setup {
          Obscenity::Base.blacklist = :default
          Obscenity::Base.whitelist = ['biatch']
        }
        should "return an array with the offensive words based on the default blacklist and custom whitelist" do
          assert_equal ['assclown'], Obscenity::Base.offensive('Yo assclown, sup')
          assert_equal [], Obscenity::Base.offensive('Yo biatch, sup')
        end
      end
      context "with custom blacklist/whitelist config" do
        setup {
          Obscenity::Base.blacklist = ['clown', 'biatch']
          Obscenity::Base.whitelist = ['biatch']
        }
        should "return an array with the offensive words based on the custom list" do
          assert_equal ['clown'], Obscenity::Base.offensive('Yo clown, sup')
          assert_equal [], Obscenity::Base.offensive('Yo biatch, sup')
        end
      end
    end
  end

  context "#replace" do
    should "replace the given word by the given replacement method" do
      [
        [:vowels,        {original: "Oh 5hit", clean: "Oh 5h*t"}],
        [:nonconsonants, {original: "Oh 5hit", clean: "Oh *h*t"}],
        [:stars,         {original: "Oh 5hit", clean: "Oh ****"}],
        [:garbled,       {original: "Oh 5hit", clean: "Oh $@!#%"}],
        [:default,       {original: "Oh 5hit", clean: "Oh $@!#%"}],
        ["[censored]",   {original: "Oh 5hit", clean: "Oh [censored]"}],
        [nil,            {original: "Oh 5hit", clean: "Oh $@!#%"}]
      ].each do |replacement_method, content|
        assert_equal content[:clean], Obscenity::Base.replacement(replacement_method).sanitize(content[:original]), "(replacement should match for #{replacement_method})"
      end
    end
  end

end

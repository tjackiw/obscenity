require 'helper'

class TestBase < Test::Unit::TestCase

  context "#respond_to?" do
    should "respond to methods and attributes" do
      [:blocklist, :allowlist, :profane?, :sanitize, :replacement, :offensive, :replace].each do |field|
        assert Obscenity::Base.respond_to?(field)
      end
    end
  end

  context "#blocklist" do
    context "without custom config" do
      setup { Obscenity::Base.blocklist = :default }
      should "use the default content file when no config is found" do
        assert Obscenity::Base.blocklist.is_a?(Array)
        assert_equal 565, Obscenity::Base.blocklist.size
      end
    end
    context "with custom config" do
      setup { Obscenity::Base.blocklist = ['bad', 'word'] }
      should "respect the config options" do
        assert_equal ['bad', 'word'], Obscenity::Base.blocklist
      end
    end
  end

  context "#allowlist" do
    context "without custom config" do
      setup { Obscenity::Base.allowlist = :default }
      should "use the default content file when no config is found" do
        assert Obscenity::Base.allowlist.is_a?(Array)
        assert Obscenity::Base.allowlist.empty?
      end
    end
    context "with custom config" do
      setup { Obscenity::Base.allowlist = ['safe', 'word'] }
      should "respect the config options" do
        assert_equal ['safe', 'word'], Obscenity::Base.allowlist
      end
    end
  end

  context "#profane?" do
    context "without allowlist" do
      context "without custom config" do
        setup {
          Obscenity::Base.blocklist = :default
          Obscenity::Base.allowlist = :default
        }
        should "validate the profanity of a word based on the default list" do
          assert Obscenity::Base.profane?('ass')
          assert Obscenity::Base.profane?('biatch')
          assert !Obscenity::Base.profane?('hello')
        end
      end
      context "with custom blocklist config" do
        setup { Obscenity::Base.blocklist = ['ass', 'word'] }
        should "validate the profanity of a word based on the custom list" do
          assert Obscenity::Base.profane?('ass')
          assert Obscenity::Base.profane?('word')
          assert !Obscenity::Base.profane?('biatch')
        end
      end
    end
    context "with allowlist" do
      context "without custom blocklist config" do
        setup {
          Obscenity::Base.blocklist = :default
          Obscenity::Base.allowlist = ['biatch']
        }
        should "validate the profanity of a word based on the default list" do
          assert Obscenity::Base.profane?('ass')
          assert !Obscenity::Base.profane?('biatch')
          assert !Obscenity::Base.profane?('hello')
        end
      end
      context "with custom blocklist/allowlist config" do
        setup {
          Obscenity::Base.blocklist = ['ass', 'word']
          Obscenity::Base.allowlist = ['word']
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
    context "without allowlist" do
      context "without custom config" do
        setup {
          Obscenity::Base.blocklist = :default
          Obscenity::Base.allowlist = :default
        }
        should "sanitize and return a clean text based on the default list" do
          assert_equal "Yo $@!#%, sup", Obscenity::Base.sanitize('Yo assclown, sup')
          assert_equal "Hello world", Obscenity::Base.sanitize('Hello world')
        end
      end
      context "with custom blocklist config" do
        setup { Obscenity::Base.blocklist = ['ass', 'word'] }
        should "sanitize and return a clean text based on a custom list" do
          assert_equal "Yo $@!#%, sup", Obscenity::Base.sanitize('Yo word, sup')
          assert_equal "Hello world", Obscenity::Base.sanitize('Hello world')
        end
      end
    end
    context "with allowlist" do
      context "without custom blocklist config" do
        setup {
          Obscenity::Base.blocklist = :default
          Obscenity::Base.allowlist = ['biatch']
        }
        should "sanitize and return a clean text based on the default blocklist and custom allowlist" do
          assert_equal "Yo $@!#%, sup", Obscenity::Base.sanitize('Yo assclown, sup')
          assert_equal "Yo biatch, sup", Obscenity::Base.sanitize('Yo biatch, sup')
        end
      end
      context "with custom blocklist/allowlist config" do
        setup {
          Obscenity::Base.blocklist = ['clown', 'biatch']
          Obscenity::Base.allowlist = ['biatch']
        }
        should "validate the profanity of a word based on the custom list" do
          assert_equal "Yo $@!#%, sup", Obscenity::Base.sanitize('Yo clown, sup')
          assert_equal "Yo biatch, sup", Obscenity::Base.sanitize('Yo biatch, sup')
        end
      end
    end
  end

  context "#replacement" do
    context "without allowlist" do
      context "without custom config" do
        setup {
          Obscenity::Base.blocklist = :default
          Obscenity::Base.allowlist = :default
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
      context "with custom blocklist config" do
        setup { Obscenity::Base.blocklist = ['ass', 'word', 'w0rd'] }
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
    context "with allowlist" do
      context "without custom blocklist config" do
        setup {
          Obscenity::Base.blocklist = :default
          Obscenity::Base.allowlist = ['biatch']
        }
        should "sanitize and return a clean text based on the default blocklist and custom allowlist" do
          assert_equal "Yo ********, sup", Obscenity::Base.replacement(:stars).sanitize('Yo assclown, sup')
          assert_equal "Yo $@!#%, sup", Obscenity::Base.replacement(:garbled).sanitize('Yo assclown, sup')
          assert_equal "Yo *sscl*wn, sup", Obscenity::Base.replacement(:vowels).sanitize('Yo assclown, sup')
          assert_equal "What an *r**", Obscenity::Base.replacement(:nonconsonants).sanitize('What an ar5e')
          assert_equal "Yo [censored], sup", Obscenity::Base.replacement('[censored]').sanitize('Yo assclown, sup')
          assert_equal "Yo biatch, sup", Obscenity::Base.replacement(:default).sanitize('Yo biatch, sup')
        end
      end
      context "with custom blocklist/allowlist config" do
        setup {
          Obscenity::Base.blocklist = ['clown', 'biatch']
          Obscenity::Base.allowlist = ['biatch']
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
    context "without allowlist" do
      context "without custom config" do
        setup {
          Obscenity::Base.blocklist = :default
          Obscenity::Base.allowlist = :default
        }
        should "return an array with the offensive words based on the default list" do
          assert_equal ['assclown'], Obscenity::Base.offensive('Yo assclown, sup')
          assert_equal [], Obscenity::Base.offensive('Hello world')
        end
      end
      context "with custom blocklist config" do
        setup { Obscenity::Base.blocklist = ['yo', 'word'] }
        should "return an array with the offensive words based on a custom list" do
          assert_equal ['yo', 'word'], Obscenity::Base.offensive('Yo word, sup')
          assert_equal [], Obscenity::Base.offensive('Hello world')
        end
      end
    end
    context "with allowlist" do
      context "without custom blocklist config" do
        setup {
          Obscenity::Base.blocklist = :default
          Obscenity::Base.allowlist = ['biatch']
        }
        should "return an array with the offensive words based on the default blocklist and custom allowlist" do
          assert_equal ['assclown'], Obscenity::Base.offensive('Yo assclown, sup')
          assert_equal [], Obscenity::Base.offensive('Yo biatch, sup')
        end
      end
      context "with custom blocklist/allowlist config" do
        setup {
          Obscenity::Base.blocklist = ['clown', 'biatch']
          Obscenity::Base.allowlist = ['biatch']
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

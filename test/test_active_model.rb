require 'helper'

class TestActiveModel < Test::Unit::TestCase
  
  def generate_new_class(name, options = {})
    Dummy.send(:remove_const, name) if Dummy.const_defined?(name)
    klass = Class.new(Dummy::BaseModel) do
      validates :title, options
    end
    Dummy.const_set(name, klass)
  end

  should "be invalid when title is profane" do
    klass = generate_new_class("Post", obscenity: true)
    post  = klass.new(title: "He who poops, shits itself")
    assert !post.valid?
    assert post.errors.has_key?(:title)
    assert_equal ['cannot be profane'], post.errors[:title]
  end

  should "be invalid when title is profane and should include a custom error message" do
    klass = generate_new_class("Post", obscenity: { message: "can't be profane!" })
    post  = klass.new(title: "He who poops, shits itself")
    assert !post.valid?
    assert post.errors.has_key?(:title)
    assert_equal ["can't be profane!"], post.errors[:title]
  end

  should "sanitize the title using the default replacement" do
    klass = generate_new_class("Post", obscenity: { sanitize: true })
    post  = klass.new(title: "He who poops, shits itself")
    assert post.valid?
    assert !post.errors.has_key?(:title)
    assert_equal "He who poops, $@!#% itself", post.title
  end
  
  should "sanitize the title using the :garbled replacement" do
    klass = generate_new_class("Post", obscenity: { sanitize: true, replacement: :garbled })
    post  = klass.new(title: "He who poops, shits itself")
    assert post.valid?
    assert !post.errors.has_key?(:title)
    assert_equal "He who poops, $@!#% itself", post.title
  end

  should "sanitize the title using the :stars replacement" do
    klass = generate_new_class("Post", obscenity: { sanitize: true, replacement: :stars })
    post  = klass.new(title: "He who poops, shits itself")
    assert post.valid?
    assert !post.errors.has_key?(:title)
    assert_equal "He who poops, ***** itself", post.title
  end

  should "sanitize the title using the :vowels replacement" do
    klass = generate_new_class("Post", obscenity: { sanitize: true, replacement: :vowels })
    post  = klass.new(title: "He who poops, shits itself")
    assert post.valid?
    assert !post.errors.has_key?(:title)
    assert_equal "He who poops, sh*ts itself", post.title
  end

  should "sanitize the title using a custom replacement" do
    klass = generate_new_class("Post", obscenity: { sanitize: true, replacement: '[censored]' })
    post  = klass.new(title: "He who poops, shits itself")
    assert post.valid?
    assert !post.errors.has_key?(:title)
    assert_equal "He who poops, [censored] itself", post.title
  end

end

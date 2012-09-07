require 'obscenity/error'
require 'obscenity/config'
require 'obscenity/base'
require 'obscenity/version'

if defined?(::RSpec)
  require 'obscenity/rspec_matcher'
end

module Obscenity extend self
  
  attr_accessor :config
  
  def configure(&block)
    @config = Config.new(&block)
  end
  
  def config
    @config ||= Config.new
  end
  
  def profane?(word)
    Obscenity::Base.profane?(word)
  end
  
  def sanitize(text)
    Obscenity::Base.sanitize(text)
  end
  
  def replacement(chars)
    Obscenity::Base.replacement(chars)
  end

  def offensive(text)
    Obscenity::Base.offensive(text)
  end
  
  
end
  

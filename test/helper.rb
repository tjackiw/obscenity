require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'active_model'
require 'obscenity'
require 'obscenity/active_model'

module Dummy
  class BaseModel
    include ActiveModel::Validations
  
    attr_accessor :title

    def initialize(attr_names)
      attr_names.each{ |k,v| send("#{k}=", v) }
    end
  end
end

class Test::Unit::TestCase
end

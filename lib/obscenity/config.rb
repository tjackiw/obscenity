module Obscenity
  class Config
    
    attr_accessor :replacement
    
    DEFAULT_WHITELIST = []
    DEFAULT_BLACKLIST = File.dirname(__FILE__) + "/../../config/blacklist.yml"
    
    def initialize
      yield(self) if block_given?
      validate_config_options
    end
    
    def replacement
      @replacement ||= :garbled
    end
    
    def blacklist
      @blacklist ||= DEFAULT_BLACKLIST
    end
    
    def blacklist=(value)
      @blacklist = value == :default ? DEFAULT_BLACKLIST : value
    end
    
    def whitelist
      @whitelist ||= DEFAULT_WHITELIST
    end
    
    def whitelist=(value)
      @whitelist = value == :default ? DEFAULT_WHITELIST : value
    end
    
    private
    def validate_config_options
      [@blacklist, @whitelist].each{ |content| validate_list_content(content) if content }
    end
    
    def validate_list_content(content)
      case content
      when Array    then !content.empty?       || raise(Obscenity::EmptyContentList.new('Content array is empty.'))
      when String   then File.exists?(content) || raise(Obscenity::UnkownContentFile.new("Content file can't be found."))
      when Pathname then content.exist?        || raise(Obscenity::UnkownContentFile.new("Content file can't be found."))
      when Symbol   then content == :default   || raise(Obscenity::UnkownContent.new("The only accepted symbol is :default."))
      else
        raise Obscenity::UnkownContent.new("The content can be either an Array, Pathname, or String path to a .yml file.")
      end
    end
    
  end
end
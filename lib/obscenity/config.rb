module Obscenity
  class Config
    
    attr_accessor :replacement
    
    DEFAULT_WHITELIST = []
    DEFAULT_BLACKLIST = File.dirname(__FILE__) + "/../../config/blacklist.yml"
    
    def initialize
      @init = true
      yield(self) if block_given?
      @init = false

      validate_config_options
      update_base_lists
    end
    
    def replacement
      @replacement ||= :garbled
    end
    
    def blacklist
      @blacklist ||= DEFAULT_BLACKLIST
    end
    
    def blacklist=(value)
      @blacklist = value == :default ? DEFAULT_BLACKLIST : value
      if @init
        @update_blacklist = true
      else
        Base.blacklist = set_list_content(@blacklist)
      end
    end
    
    def whitelist
      @whitelist ||= DEFAULT_WHITELIST
    end
    
    def whitelist=(value)
      @whitelist = value == :default ? DEFAULT_WHITELIST : value
      if @init
        @update_whitelist = true
      else
        Base.whitelist = set_list_content(@whitelist)
      end
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

    def update_base_lists
      Base.blacklist = set_list_content(@blacklist) if @update_blacklist
      Base.whitelist = set_list_content(@whitelist) if @update_whitelist
    end

    def set_list_content(list)
      case list
      when Array then list
      when String, Pathname then YAML.load_file( list.to_s )
      else []
      end
    end
    
  end
end
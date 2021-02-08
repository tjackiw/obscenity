module Obscenity
  class Config

    attr_accessor :replacement

    DEFAULT_ALLOWLIST = []
    DEFAULT_BLOCKLIST = File.dirname(__FILE__) + "/../../config/blocklist.yml"

    def initialize
      yield(self) if block_given?
      validate_config_options
    end

    def replacement
      @replacement ||= :garbled
    end

    def blocklist
      @blocklist ||= DEFAULT_BLOCKLIST
    end

    def blocklist=(value)
      @blocklist = value == :default ? DEFAULT_BLOCKLIST : value
    end

    def allowlist
      @allowlist ||= DEFAULT_ALLOWLIST
    end

    def allowlist=(value)
      @allowlist= value == :default ? DEFAULT_ALLOWLIST : value
    end

    private
    def validate_config_options
      [@blocklist, @allowlist].each{ |content| validate_list_content(content) if content }
    end

    def validate_list_content(content)
      case content
      when Array    then !content.empty?       || raise(Obscenity::EmptyContentList.new('Content array is empty.'))
      when String   then File.exists?(content) || raise(Obscenity::UnknownContentFile.new("Content file can't be found."))
      when Pathname then content.exist?        || raise(Obscenity::UnknownContentFile.new("Content file can't be found."))
      when Symbol   then content == :default   || raise(Obscenity::UnknownContent.new("The only accepted symbol is :default."))
      else
        raise Obscenity::UnknownContent.new("The content can be either an Array, Pathname, or String path to a .yml file.")
      end
    end

  end
end

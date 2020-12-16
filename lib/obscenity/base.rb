module Obscenity
  class Base
    class << self

      def blocklist
        @blocklist ||= set_list_content(Obscenity.config.blocklist)
      end

      def blocklist=(value)
        @blocklist = value == :default ? set_list_content(Obscenity::Config.new.blocklist) : value
      end

      def allowlist
        @allowlist ||= set_list_content(Obscenity.config.allowlist)
      end

      def allowlist=(value)
        @allowlist = value == :default ? set_list_content(Obscenity::Config.new.allowlist) : value
      end

      def profane?(text)
        return(false) unless text.to_s.size >= 3
        blocklist.each do |foul|
          return(true) if text =~ /\b#{foul}\b/i && !allowlist.include?(foul)
        end
        false
      end

      def sanitize(text)
        return(text) unless text.to_s.size >= 3
        blocklist.each do |foul|
          text.gsub!(/\b#{foul}\b/i, replace(foul)) unless allowlist.include?(foul)
        end
        @scoped_replacement = nil
        text
      end

      def replacement(chars)
        @scoped_replacement = chars
        self
      end

      def offensive(text)
        words = []
        return(words) unless text.to_s.size >= 3
        blocklist.each do |foul|
          words << foul if text =~ /\b#{foul}\b/i && !allowlist.include?(foul)
        end
        words.uniq
      end

      def replace(word)
        content = @scoped_replacement || Obscenity.config.replacement
        case content
        when :vowels then word.gsub(/[aeiou]/i, '*')
        when :stars  then '*' * word.size
        when :nonconsonants then word.gsub(/[^bcdfghjklmnpqrstvwxyz]/i, '*')
        when :default, :garbled then '$@!#%'
        else content
        end
      end

      private
      def set_list_content(list)
        case list
        when Array then list
        when String, Pathname then YAML.load_file( list.to_s )
        else []
        end
      end

    end
  end
end

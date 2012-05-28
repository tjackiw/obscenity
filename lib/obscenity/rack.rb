module Rack
  class Obscenity
        
    def initialize(app, options = {})  
      @app, @options = app, options
    end  
    
    def call(env)
      rejectable  = false
      post_params = Rack::Utils.parse_query(env['rack.input'].read, "&")
      get_params  = Rack::Utils.parse_query(env['QUERY_STRING'],    "&")
      
      if @options.has_key?(:reject)
        rejactable = validate_rejectability_of( select_params(:reject, get_params.update(post_params)) )
      
      elsif @options.has_key?(:sanitize)
        get_params  = sanitize_contents_of(get_params)
        post_params = sanitize_contents_of(post_params)
        
        env['QUERY_STRING'] = Rack::Utils.build_query(get_params)
        env['rack.input']   = StringIO.new(Rack::Utils.build_query(post_params))
      end
      
      rejactable ? reject : continue(env)
    end
    
    private
    def continue(env)
      @app.call(env)
    end
    
    def reject
      length, content = 0, ''
      if @options[:reject].is_a?(Hash) 
        if (message = @options[:reject][:message]).present?
          content = message
          length  = message.size
        elsif (path = @options[:reject][:path]).present?
          if (path = ::File.expand_path(path)) && ::File.exists?(path)
            content = ::File.read(path)
            length  = content.size
          end
        end
      end

      [422, {'Content-Type' => 'text/html', 'Content-Length' => length.to_s}, [content]]
    end

    def validate_rejectability_of(params = {})
      should_reject_request = false
      params.each_pair do |param, value|
        if value.is_a?(Hash)
          validates_rejectability_of(value)
        elsif value.is_a?(String)
          next unless value.size >= 3
          if ::Obscenity.profane?(value)
            should_reject_request = true
            break
          end
        else
          next
        end
      end
      should_reject_request
    end
        
    def sanitize_contents_of(params)
      sanitized_params   = {}
      replacement_method = @options[:sanitize].is_a?(Hash) && @options[:sanitize][:replacement]
      select_params(:sanitize, params).each{|param, value|
        if value.is_a?(String)
          next unless value.size >= 3
          sanitized_params[param] = ::Obscenity.replacement(replacement_method).sanitize(value)
        else
          next
        end
      }
      params.update(sanitized_params)
    end
    
    def select_params(key, params = {})
      if @options[key].is_a?(Hash) && @options[key][:params].is_a?(Array)
        params.select{ |param, vvalue| @options[key][:params].include?(param.to_sym) } 
      else
        params
      end
    end
  end
end
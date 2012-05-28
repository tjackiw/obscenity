if defined?(ActiveModel)
  module ActiveModel
    module Validations
      class ObscenityValidator < ActiveModel::EachValidator
        
        def validate_each(record, attribute, value)
          if options.present? && options.has_key?(:sanitize)
            object = record.respond_to?(:[]) ? record[attribute] : record.send(attribute)
            object = Obscenity.replacement(options[:replacement]).sanitize(object)
          else
            record.errors.add(attribute, options[:message] || 'cannot be profane') if Obscenity.profane?(value)
          end
        end
        
      end
    end
  end
end

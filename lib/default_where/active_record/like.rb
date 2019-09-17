# frozen_string_literal: true

module DefaultWhere
  module ActiveRecord
    module Like
      PATTERN = ['-like', '-rl', '-ll'].freeze
  
      def dw_like_scope(params, operator: 'AND')
        where_string = []
        where_hash = {}
  
        params.each do |key, value|
          real_key = key.sub(/-(like|rl|ll)$/, '')
          agent_key = key.gsub(/[-.]/, '_')
  
          where_string << "#{real_key} like :#{agent_key}"
  
          if key.end_with?('-ll')
            like_value = "#{value}%"
          elsif key.end_with?('-rl')
            like_value = "%#{value}"
          else
            like_value = "%#{value}%"
          end
  
          where_hash.merge! agent_key.to_sym => like_value
        end
  
        where_string = where_string.join " #{operator} "
  
        if where_string.present?
          condition = [where_string, where_hash]
          where(condition)
        else
          current_scope
        end
      end
  
      def dw_like_filter(params)
        params.select do |k, _|
          k.end_with?(*PATTERN)
        end
      end
      
    end
  end
end

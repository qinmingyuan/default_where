# frozen_string_literal: true

module DefaultWhere
  module ActiveRecord
    module Range
      PATTERN = {
        '-gt' => '>',
        '-gte' => '>=',
        '-lt' => '<',
        '-lte' => '<=',
        '-not' => '!='
      }.freeze
      
      def dw_range_scope(params, operator: 'AND')
        where_string = []
        where_hash = {}
  
        params.each do |key, value|
          raise "#{key}'s value dot support nil" if value.nil?
          
          exp = /-(gt|gte|lt|lte|not)$/
          real_key = key.sub(exp, '')
          sign_str = key.match(exp).to_s
          agent_key = key.gsub(/[-.]/, '_')
  
          where_string << "#{real_key} #{PATTERN[sign_str]} :#{agent_key}"
  
          where_hash.merge! agent_key.to_sym => value
        end
  
        where_string = where_string.join " #{operator} "
  
        if where_string.present?
          condition = [where_string, where_hash]
          where(condition)
        else
          current_scope
        end
      end
  
      def dw_range_filter(params)
        params.select do |k, _|
          k.end_with?(*PATTERN.keys)
        end
      end
      
    end
  end
end

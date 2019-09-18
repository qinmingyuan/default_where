# frozen_string_literal: true

module DefaultWhere
  module ActiveRecord
    module Or
    
    def dw_or_scope(params)
      where_string = []
      where_hash = {}

      params.each do |key, value|
        agent_key = key.gsub(/[-.]/, '_')
  
        if value.nil?
          where_string << "#{key} IS NULL"
        else
          where_string << "#{key} = :#{agent_key}"
          where_hash.merge! agent_key.to_sym => value
        end
      end

      where_string = where_string.join " OR "

      if where_string.present?
        condition = [where_string, where_hash]
        where(condition)
      else
        current_scope
      end
    end
    
    end
  end
end


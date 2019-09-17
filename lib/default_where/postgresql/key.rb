# frozen_string_literal: true

# for i18n jsonb support search
module DefaultWhere
  module Postgresql
    module Key
  
      def dw_key_scope(params, operator: 'AND')
        where_string = []
        where_hash = {}
  
        params.each do |key, value|
          real_key, i18n_key = key.split('/')
          agent_key = key.gsub(/[\/.]/, '_')
  
          where_string << "#{real_key}->>'#{i18n_key}' = :#{agent_key}"
          where_hash.merge! agent_key.to_sym => value
        end
  
        where_string = where_string.join " #{operator} "
  
        if where_string.present?
          condition = [where_string, where_hash]
          where(condition)
        else
          all
        end
      end
  
      def dw_key_filter(params)
        params.select do |k, _|
          k.match? /.\/./
        end
      end
    
    end
  end
end


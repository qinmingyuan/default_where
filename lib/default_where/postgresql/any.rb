# frozen_string_literal: true

# for postgresql array search
module DefaultWhere
  module Postgresql
    module Any
  
      def dw_any_scope(params)
        where_string = []
        where_hash = {}
  
        params.each do |key, value|
          real_key = key.sub(/-(any)$/, '')
          agent_key = key.gsub(/[-.]/, '_')
  
          where_string << ":#{agent_key} = ANY(#{real_key})"
          where_hash.merge! agent_key.to_sym => value
        end
        
        [where_string, where_hash]
      end
  
      def dw_any_filter(params)
        params.select do |k, _|
          k.end_with?('-any')
        end
      end
    
    end
  end
end


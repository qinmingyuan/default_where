# frozen_string_literal: true

module DefaultWhere
  module ActiveRecord
    module Order

      def order_scope(params)
        order_array = []
  
        params.sort_by{ |_, v| v.to_i }.each do |i|
          order_array << i[0].sub(/-(asc|desc)$/, '-asc' => ' ASC', '-desc' => ' DESC')
        end
  
        order(order_array)
      end
  
      def filter_order(params)
        params.select do |k, v|
          k.end_with?('-asc', '-desc') && String(v) =~ /^[1-9]$/
        end
      end
    
    end
  end
end

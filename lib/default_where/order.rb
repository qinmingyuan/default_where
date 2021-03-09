# frozen_string_literal: true

module DefaultWhere
  module Order
    PATTERN = {
      '-asc': :asc,
      '-desc': :desc
    }

    def default_where_order(params)
      order_hash = {}

      params.sort_by{ |_, v| v.to_i }.each do |i|
        k, v = i[0].split('-')
        order_hash[k] = v
      end

      order(order_hash)
    end

    def default_where_order_filter(params)
      params.select do |k, v|
        k.end_with?('-asc', '-desc') && String(v) =~ /^[1-9]$/
      end
    end

  end
end

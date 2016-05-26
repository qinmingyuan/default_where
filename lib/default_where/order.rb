module DefaultWhere
  module Order

    def order_scope(params)
      order_array = []

      params.select{ |key, _| key.end_with?('-asc') }.each do |k, _|
        order_array << k.sub(/-asc$/, ' asc')
      end

      params.select{ |key, _| key.end_with?('-desc') }.each do |k, _|
        order_array << k.sub(/-desc$/, ' desc')
      end

      order(order_array)
    end

    def filter_order(params)
      params.select do |k, v|
        k =~ /o\d/ && v.end_with?('-asc', '-desc')
      end
    end

  end
end

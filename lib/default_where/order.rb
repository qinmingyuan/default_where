module DefaultWhere
  module Order

    def order_scope(params)
      @order_array = []

      order_process(params)

      order(@order_array)
    end

    def order_process(params)

      params.select{ |key, _| key.end_with?('_asc') }.each do |k, _|
        @order_array << k.sub(/_asc$/, ' asc')
      end

      params.select{ |key, _| key.end_with?('_desc') }.each do |k, _|
         @order_array << k.sub(/_desc$/, ' desc')
      end

    end

  end
end

module DefaultWhere
  module Order

    def order_scope(params, options)
      @order_array = []

      order_process(params, options)

      order(@order_array)
    end

    def order_process(params, options)

    end

  end
end

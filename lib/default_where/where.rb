module DefaultWhere
  module Where

    def where_scope(relation,params)
      params.each do |key, scope|
       relation = scope.call(relation) if scope.respond_to?(:call)
      end
      relation
    end

    def filter_where(params)
      params.select do |k, scope|
        scope.respond_to?(:call)
      end
    end

  end
end

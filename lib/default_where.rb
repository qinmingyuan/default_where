require 'default_where/equal'
require 'default_where/range'
require 'default_where/order'

module DefaultWhere
  include DefaultWhere::Equal
  include DefaultWhere::Range
  include DefaultWhere::Order

  def default_where(params = {})
    return all if params.blank?

    params = params.to_h
    params, tables = params_with_table(params)

    range_params = filter_range(params)
    params = params.except!(range_params.keys)

    order_params = filter_order(params)
    equal_params = params.except!(order_params.keys)

    includes(tables).equal_scope(equal_params)
      .range_scope(range_params)
      .order_scope(order_params)
  end

  def params_with_table(params)
    params.stringify_keys!
    params.compact!  # todo,需确认是否有必要

    tables = []

    # since 1.9 is using lazy iteration
    params.to_a.each do |key, _|
      if key =~ /-/
        assoc, column = key.split('-')
        assoc_model = reflections[assoc]
        if assoc_model
          params["#{assoc_model.table_name}.#{column}"] = params.delete(key)
          tables << assoc.to_sym
        end
      end

      if column_names.include?(key)
        params["#{table_name}.#{key}"] = params.delete(key)
      elsif !key.include?('.')
        params.delete(key)
      end
    end

    [params, tables]
  end

end

ActiveRecord::Base.extend DefaultWhere

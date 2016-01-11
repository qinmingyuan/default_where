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
    params, tables, as_s = params_with_table(params)

    range_params = filter_range(params)
    params = params.except!(range_params.keys)

    order_params = filter_order(params)
    equal_params = params.except!(order_params.keys)

    joins(as_s).equal_scope(equal_params, tables)
      .range_scope(range_params, tables)
      .order_scope(order_params)
  end

  def params_with_table(params)
    params.stringify_keys!
    params.compact!  # todo,需确认是否有必要

    tables = { table_name => self.name }
    as_s = []

    # since 1.9 is using lazy iteration
    params.to_a.each do |key, _|
      if key =~ /-/
        as, col = key.split('-')
        as_s << as.to_sym

        as_model = reflections[as]
        if as_model
          params["#{as_model.table_name}.#{col}"] = params.delete(key)
          tables[as_model.table_name] = as_model.class_name
        end
      end

      if column_names.include?(key)
        params["#{table_name}.#{key}"] = params.delete(key)
      elsif !key.include?('.')
        params.delete(key)
      end
    end

    [params, tables, as_s]
  end

end

ActiveRecord::Base.extend DefaultWhere

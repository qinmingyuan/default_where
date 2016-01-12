require 'default_where/equal'
require 'default_where/range'
require 'default_where/order'

module DefaultWhere
  include DefaultWhere::Equal
  include DefaultWhere::Range
  include DefaultWhere::Order

  def default_where(params = {})
    return all if params.blank?

    params, tables = params_with_table(params)

    range_params = filter_range(params)
    params = params.except!(range_params.keys)

    order_params = filter_order(params)
    params = params.except!(order_params.keys)

    not_params = filter_not(params)
    equal_params = params.except!(not_params.keys)

    joins(tables.keys).equal_scope(equal_params)
      .not_scope(not_params)
      .range_scope(range_params)
      .order_scope(order_params)
  end

  def params_with_table(params)
    params.permit! if params.respond_to?(:permitted?) && !params.permitted?
    params = params.to_h
    params.stringify_keys!
    params.reject! { |_, value| value.blank? }

    tables = { }

    # since 1.9 is using lazy iteration
    params.to_a.each do |key, _|
      if key =~ /-/
        as, col = key.split('-')
        as_model = reflections[as]

        if as_model
          params["#{as_model.table_name}.#{col}"] = params.delete(key)
          tables[as] = as_model.table_name
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

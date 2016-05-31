require 'default_where/not'
require 'default_where/range'
require 'default_where/order'

module DefaultWhere
  include DefaultWhere::Not
  include DefaultWhere::Range
  include DefaultWhere::Order

  def default_where(params = {})
    return all if params.blank?

    params, tables = params_with_table(params)

    range_params = filter_range(params)
    params = params.except!(*range_params.keys)

    order_params = filter_order(params)
    params = params.except!(*order_params.keys)

    not_params = filter_not(params)
    equal_params = params.except!(*not_params.keys)

    joins(tables).where(equal_params)
      .not_scope(not_params)
      .range_scope(range_params)
      .order_scope(order_params)
  end

  def params_with_table(params)
    if params.respond_to?(:permitted?) && !params.permitted?
      params.permit!
    end

    params = params.to_h
    params.stringify_keys!
    params.reject! { |_, value| value.blank? }

    tables = []

    # since 1.9 is using lazy iteration
    params.to_a.each do |key, _|

      if key =~ /\./
        as, col = key.split('.')
        f_col, _ = col.split('-')
        as_model = reflections[as]

        if as_model && as_model.klass.column_names.include?(f_col)
          params["#{as_model.table_name}.#{col}"] = params.delete(key)
          tables << as.to_sym
        else
          params.delete(key)
        end
      else
        f_key, _ = key.split('-')
        if column_names.include?(f_key)
          params["#{table_name}.#{key}"] = params.delete(key)
        else
          params.delete(key)
        end
      end

    end

    [params, tables]
  end

end

ActiveRecord::Base.extend DefaultWhere

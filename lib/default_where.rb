require 'default_where/equal'
require 'default_where/range'
require 'default_where/order'

module DefaultWhere
  include DefaultWhere::Equal
  include DefaultWhere::Range
  include DefaultWhere::Order

  # options：
  # <association_name> => <column_name>
  # student: 'teacher_id'
  def default_where(params = {}, options = {})
    return all if params.blank?

    params = params.to_h
    params = params_with_table(params, options)

    range_params = filter_range(params)
    params = params.except!(range_params.keys)

    order_params = filter_order(params)
    equal_params = params.except!(order_params.keys)

    include = options.present? && !self.values.keys.include?(:includes)

    if include
      includes(options.keys)
    end

    range_scope(range_params)
    equal_scope(equal_params)

    #order_scope(order_params, options)
  end

  def filter_range(params)
    params.select do |k, _|
      k.end_with?('_gt', '_gte', '_lt', '_lte')
    end
  end

  def filter_order(params)
    params.select do |k, _|
      k.end_with?('_asc', '_desc')
    end
  end

  # params with table
  def params_with_table(params, options)
    params.stringify_keys!
    params.compact!

    options.each do |assoc, column|
      assoc_model = reflections[assoc.to_s]

      if assoc_model
        params.select{ |k, _| k.start_with?(column.to_s) }.each do |k, _|
          params["#{assoc_model.table_name}.#{k}"] = params.delete(k)
        end
      else
        raise 'Wrong Association Name'
      end
    end

    # since 1.9 is using lazy iteration
    params.to_a.each do |key, _|
      if column_names.include?(key)
        params["#{table_name}.#{key}"] = params.delete(key.to_s)
      elsif !key.include?('.')
        params.delete(key.to_s)
      end
    end

    params
  end

end

ActiveRecord::Base.extend DefaultWhere

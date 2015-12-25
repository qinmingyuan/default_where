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

    if tables.present? && !self.values.keys.include?(:includes) # 本身不包含includes方法
      includes(tables)
    end

    range_scope(range_params)
    equal_scope(equal_params)
    order_scope(order_params)
  end

  def filter_range(params)
    params.select do |k, _|
      k.end_with?('_gt', '_gte', '_lt', '_lte')
    end
  end

  def filter_order(params)
    params.select do |k, v|
      k =~ /o\d/ && v.end_with?('_asc', '_desc')
    end
  end

  # params with table
  def params_with_table(params)
    params.stringify_keys!
    params.compact!

    params.each do |k, _|
      if k =~ /-/
        assoc, column = k.split('-')
        assoc_model = reflections[assoc]
        params["#{assoc_model.table_name}.#{column}"] = params.delete(k) if assoc_model
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

    [params, tables]
  end

end

ActiveRecord::Base.extend DefaultWhere

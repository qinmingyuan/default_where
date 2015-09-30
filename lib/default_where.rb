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

    params.stringify_keys!
    params.compact!

    check_options(options)

    range_params = filter_range(params)
    params = params.except!(range_params.keys)

    order_params = filter_order(params)
    equal_params = params.except!(order_params.keys)

    include = options.present? && !self.values.keys.include?(:includes)

    if include
      includes(options.keys)
    end

    if range_params.present?
      range_scope(range_params, options)
    end

    if equal_params.present?
      equal_scope(equal_params, options)
    end

    if order_params
      order_scope(order_params, options)
    end
  end

  private

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

  def check_options(options)
    options.each do |assoc, column|
      assoc_model = reflections[assoc.to_sym]
      value = params[column.to_s]

      if assoc_model && value
        params.select{ |k, _| k.start_with?(column.to_s) }.each do |key, _|
          params["#{assoc_model.table_name}.#{key}"] = value
        end
        params.delete(column.to_s)
      else
        raise 'Wrong Association Name'
      end
    end
  end

end

ActiveRecord::Base.extend DefaultWhere

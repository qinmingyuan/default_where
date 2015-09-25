module DefaultWhere
  require 'default_where/equal'
  require 'default_where/range'
  #require 'default_where/order'
  include DefaultWhere::Equal
  include DefaultWhere::Range
  #include DefaultWhere::Order

  # options：
  # <association_name> => <column_name>
  # student: 'teacher_id'
  def default_where(params = {}, options = {}, include = true)
    return all if params.blank?

    params = filter_params(params)
    range_params = filter_range(params)
    order_params = filter_order(params)
    equal_params = params.except!(range_params.keys)

    include = options.present? && include

    if include && range_params.present?
      includes(options.keys).range_scope(range_params, options).equal_scope(equal_params, options)
    elsif include && range_params.blank?
      includes(options.keys).equal_scope(equal_params, options)
    elsif !include && range_params.present?
      range_scope(range_params, options).equal_scope(equal_params, options)
    elsif !include && range_params.blank?
      equal_scope(equal_params, options)
    end

    if order_params
      default_where(params, options, include).order_scope(order_params, options)
    end
  end

  private
  # remove blank values
  def filter_params(params)
    params.select { |_, v| v.present? }
  end

  def filter_range(params)
    params.select do |k, _|
      k.end_with?('gt', 'gte', 'lt', 'lte')
    end
  end

  def filter_order(params)
    params.select do |k, _|
      k.end_with?('asc', 'desc')
    end
  end

end

ActiveRecord::Base.extend DefaultWhere

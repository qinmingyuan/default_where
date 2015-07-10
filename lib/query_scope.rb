require 'query_scope/equal'
require 'query_scope/range'
module QueryScope
  include QueryScope::Equal
  include QueryScope::Range

  # 参数格式
  # options 格式：
  # <association_name> => <column_name>
  # student: 'teacher_id'
  def query_scope(params, options = {}, include = true)
    params ||= {}

    params = filter_params(params)
    range_params = filter_range(params)
    equal_params = params.except!(range_params.keys)

    if include && range_params.present?
      includes(options.keys).range_scope(range_params, options).equal_scope(equal_params, options)
    elsif include && range_params.blank?
      includes(options.keys).equal_scope(equal_params, options)
    elsif !include && range_params.present?
      range_scope(range_params, options).equal_scope(equal_params, options)
    elsif !include && range_params.blank?
      equal_scope(equal_params, options)
    end
  end

  private
  # remove blank values
  def filter_params(params)
    params.select { |_, v| v.present? }
  end

  def filter_range(params)
    params.select do |key, _|
      key.end_with?('gt', 'gte', 'lt', 'lte')
    end
  end

end

ActiveRecord::Base.extend QueryScope

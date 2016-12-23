require 'default_where/not'
require 'default_where/range'
require 'default_where/like'
require 'default_where/order'

module DefaultWhere
  include DefaultWhere::Not
  include DefaultWhere::Range
  include DefaultWhere::Order
  include DefaultWhere::Like

  REJECT = ['', ' ', nil]


  def default_where(params = {}, options = {})
    return all if params.blank?

    params, refs, tables = params_with_table(params, options)

    range_params = filter_range(params)
    order_params = filter_order(params)
    not_params = filter_not(params)
    like_params = filter_like(params)

    equal_params = params.except!(*range_params.keys, *order_params.keys, *not_params.keys, *like_params.keys)

    includes(refs).where(equal_params).references(tables)
      .not_scope(not_params)
      .like_scope(like_params)
      .range_scope(range_params)
      .order_scope(order_params)
  end

  def params_with_table(params = {}, options = {})
    if options[:reject]
      default_reject = options[:reject]
    elsif options[:allow]
      default_reject = REJECT - options[:allow]
    else
      default_reject = REJECT
    end

    params = params.to_h
    params.stringify_keys!
    params.reject! { |_, value| default_reject.include?(value) }

    refs = []
    tables = []
    final_params = {}

    params.each do |key, _|
      if key =~ /\./
        table, col = key.split('.')
        as_model = reflections[table]
        f_col, _ = col.split('-')

        if as_model && as_model.klass.column_names.include?(f_col)
          final_params["#{as_model.table_name}.#{col}"] = params[key]
          tables << as_model.table_name
          refs << table.to_sym
        elsif connection.data_sources.include? table
          final_params["#{table}.#{col}"] = params[key]
          tables << table
          keys = reflections.select { |_, v| v.table_name == table }.keys
          if keys && keys.size == 1
            refs << keys.first.to_sym
          end
          next
        end
      else
        f_key, _ = key.split('-')
        if column_names.include?(f_key)
          final_params["#{table_name}.#{key}"] = params[key]
        end
      end
    end

    [final_params, refs, tables]
  end

end

ActiveRecord::Base.extend DefaultWhere

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

    # todo secure bug
    if params.respond_to?(:permitted?) && !params.permitted?
      params.permit!
    end

    params = params.to_h
    params.stringify_keys!
    params.reject! { |_, value| default_reject.include?(value) }

    refs = []
    tables = []

    # since 1.9 is using lazy iteration
    params.to_a.each do |key, _|

      if key =~ /\./
        table, col = key.split('.')
        f_col, _ = col.split('-')
        as_model = reflections[table]

        if as_model && as_model.klass.column_names.include?(f_col)
          params["#{as_model.table_name}.#{col}"] = params.delete(key)
          refs << table.to_sym
          tables << as_model.klass.table_name
        elsif connection.tables.include? table
          tables << table
          keys = reflections.select { |_, v| v.table_name == table }.keys
          if keys && keys.size == 1
            refs << keys.first
          end
          next
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

    [params, refs, tables]
  end

end

ActiveRecord::Base.extend DefaultWhere

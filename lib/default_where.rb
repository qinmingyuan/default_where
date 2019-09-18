# frozen_string_literal: true

require_relative 'default_where/active_record/range'
require_relative 'default_where/active_record/like'
require_relative 'default_where/active_record/order'
require_relative 'default_where/active_record/or'
require_relative 'default_where/postgresql/any'
require_relative 'default_where/postgresql/key'

module DefaultWhere
  include ActiveRecord::Range
  include ActiveRecord::Order
  include ActiveRecord::Like
  include ActiveRecord::Or
  include Postgresql::Any
  include Postgresql::Key

  REJECT = ['', nil].freeze
  STRIP = true

  def default_where(params = {})
    return all if params.blank?
    
    params = params.to_h
    options = {}
    [:strip, :allow, :reject].each do |key|
      options[key] = params.delete(key) if params[key].respond_to?(:to_hash)
    end
    or_params = params.delete(:or) { |_| {} }
    
    and_params, and_refs, and_tables = params_with_table(params, options)
    
    order_params = dw_order_filter(and_params)
    and_params.except!(*order_params.keys)

    or_params, or_refs, or_tables = params_with_table(or_params, options)

    refs = and_refs + or_refs
    tables = and_tables + or_tables
    
    includes(refs).default_where_and(and_params).default_where_or(or_params).dw_order_scope(order_params).references(tables)
  end

  def default_where_and(params = {})
    return current_scope if params.blank?
    
    range_params = dw_range_filter(params)
    like_params = dw_like_filter(params)
    any_params = dw_any_filter(params)
    key_params = dw_key_filter(params)

    equal_params = params.except!(
      *range_params.keys,
      *like_params.keys,
      *any_params.keys,
      *key_params.keys
    )

    where(equal_params).dw_range_scope(range_params).dw_any_scope(any_params).dw_key_scope(key_params).dw_like_scope(like_params)
  end
  
  def default_where_or(params = {})
    return current_scope if params.blank?

    range_params = dw_range_filter(params)
    like_params = dw_like_filter(params)
    any_params = dw_any_filter(params)
    key_params = dw_key_filter(params)

    equal_params = params.except!(
      *range_params.keys,
      *like_params.keys,
      *any_params.keys,
      *key_params.keys
    )

    dw_or_scope(equal_params).dw_range_scope(range_params, operator: 'OR').dw_any_scope(any_params, operator: 'OR').dw_key_scope(key_params, operator: 'OR').dw_like_scope(like_params, operator: 'OR')
  end

  def params_with_table(params = {}, options = {})
    refs = []
    tables = []
    final_params = {}

    params.each do |key, value|
      # strip, if assign key to false, will not works
      strip = options.fetch(:strip, {}).fetch(key, STRIP)
      value = value.strip if value.is_a?(String) && strip

      # reject
      if options.key?(:reject)
        reject = options.fetch(:reject, {}).fetch(key, REJECT)
        if reject == nil
          reject = [nil]
        elsif reject == []
          reject = [[]]
        else
          reject = Array(reject)
        end
      else
        allow = options.fetch(:allow, {}).fetch(key, [])
        if allow == nil
          allow = [nil]
        else
          allow = Array(allow)
        end
        reject = REJECT - allow
      end
      next if reject.include?(value)

      items = key.to_s.split('.')
      column = items[-1]
      real_column = column.split(/[-\/]/)[0]
      
      if items.size == 1
        next unless column_names.include?(real_column)
        table = table_name
      else
        prefix = items[0]
        ref = reflections[prefix]
        
        # 检查 prefix 是否为关联关系的名称
        if ref && !ref.polymorphic?
          table = ref.table_name
        # 检查 prefix 是否为表名，且表中存在 real_column 字段
        elsif connection.data_sources.include?(prefix) && connection.column_exists?(prefix, real_column)
          possible_refs = reflections.select { |_, v| v.table_name == prefix }
          if possible_refs.size < 1
            ref = nil
          elsif possible_refs.size == 1
            ref = possible_refs[0]
          else
            raise "#{key} makes confused, please use reflection name!"
          end
          
          table = prefix
        else
          next
        end

        if ref && !ref.klass.column_names.include?(real_column)
          next
        end
        
        if ref && !refs.include?(ref.name)
          refs << ref.name
        end

        unless tables.include?(table)
          tables << table
        end
      end
      
      final_params["#{table}.#{column}"] = value
    end

    [final_params, refs, tables]
  end
  
  def logger
    ActiveRecord::Base.logger
  end

end

ActiveSupport.on_load :active_record do
  extend DefaultWhere
end

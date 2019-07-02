# frozen_string_literal: true

require_relative 'active_record/not'
require_relative 'active_record/range'
require_relative 'active_record/like'
require_relative 'active_record/order'
#require_relative 'default_where/or'
require_relative 'postgresql/any'
require_relative 'postgresql/key'

module DefaultWhere
  module ActiveRecord
    include Not
    include Range
    include Order
    include Like
    include Postgresql::Any
    include Postgresql::Key
    #include Or
  
    REJECT = ['', nil].freeze
    STRIP = true
  
    def default_where(params = {}, options = {})
      return all if params.blank?
  
      params = params.to_h
      params, refs, tables = params_with_table(params, options)
  
      #or_params = filter_or(params)
      range_params = filter_range(params)
      order_params = filter_order(params)
      not_params = filter_not(params)
      like_params = filter_like(params)
      any_params = filter_any(params)
      key_params = filter_key(params)
  
      equal_params = params.except!(
        *range_params.keys,
        *order_params.keys,
        *not_params.keys,
        *like_params.keys,
        *any_params.keys,
        *key_params.keys
      )
  
      includes(refs).where(equal_params).references(tables)
        .not_scope(not_params)
        .like_scope(like_params)
        .range_scope(range_params)
        .order_scope(order_params)
        .any_scope(any_params)
        .key_scope(key_params)
    end
  
    def params_with_table(params = {}, options = {})
      refs = []
      tables = []
      final_params = {}
  
      params.each do |key, value|
        # strip
        strip = options.fetch(key, {}).fetch(:strip, STRIP)
        value = value.strip if value.is_a?(String) && strip
  
        # reject
        options_reject = [options.fetch(key, {}).fetch(:reject, [])].flatten
        if options_reject.present?
           reject = options_reject
        else
          allow = [options.fetch(key, {}).fetch(:allow, [])].flatten
          reject = REJECT - allow
        end
        next if reject.include?(value)
  
        # unify key to string
        key = key.to_s
  
        if key =~ /\./
          _table, _column = key.split('.')
          _real_column = _column.split('-').first
          _ref = reflections[_table]
          if _ref && _ref.klass.column_names.include?(_real_column)
            _table = _ref.table_name
          elsif connection.data_sources.include?(_table) && connection.column_exists?(_table, _real_column)
            _refs = reflections.select { |_, v| v.table_name == _table && !v.polymorphic? }
            if _refs.size == 1
              _ref = _refs.first
            else
              raise "#{key} makes confused, please use reflection name!"
            end
          else
            next
          end
          refs << _ref.name unless refs.include?(_ref.name)
          tables << _table unless tables.include?(_table)
          final_params["#{_table}.#{_column}"] = value
        else
          _real_column = key.split(/[-\/]/).first
          next unless column_names.include?(_real_column)
          final_params["#{table_name}.#{key}"] = value
        end
      end
  
      [final_params, refs, tables]
    end
    
  end
end

ActiveSupport.on_load :active_record do
  extend DefaultWhere::ActiveRecord
end

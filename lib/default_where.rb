# frozen_string_literal: true

require_relative 'default_where/active_record'
require_relative 'default_where/order'
require_relative 'default_where/params'

module DefaultWhere
  include ActiveRecord
  include Order
  include Params

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
    
    and_params, and_refs, and_tables = default_where_params(params, options)
    
    order_params = default_where_order_filter(and_params)
    and_params.except!(*order_params.keys)

    or_params, or_refs, or_tables = default_where_params(or_params, options)

    refs = and_refs + or_refs
    tables = and_tables + or_tables
    
    includes(refs).default_where_and(and_params).default_where_or(or_params).default_where_order(order_params).references(tables)
  end

  def default_where_and(params = {})
    return current_scope if params.blank?
    
    equal_params = {}
    params.each do |key, _|
      equal_params[key] = params.delete(key) unless key.match? /[-\/]/
    end
    where_string, where_hash = default_where_scope(params)
    where_string = where_string.join ' AND '

    where(equal_params).where(where_string, where_hash)
  end
  
  def default_where_or(params = {})
    return current_scope if params.blank?

    where_string, where_hash = default_where_scope(params)
    where_string = where_string.join ' OR '
    
    where(where_string, where_hash)
  end
  
  def logger
    ActiveRecord::Base.logger
  end

end

ActiveSupport.on_load :active_record do
  extend DefaultWhere
end

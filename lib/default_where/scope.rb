# frozen_string_literal: true

module DefaultWhere
  module Scope
    PATTERN = {
      gt: '>',
      gte: '>=',
      lt: '<',
      lte: '<=',
      not: '!=',
      like: 'LIKE',
      rl: 'LIKE',
      ll: 'LIKE',
      :'' => '='
    }.freeze
    POSTGRES_PATTERN = {
      like: 'ILIKE',
      rl: 'ILIKE',
      ll: 'ILIKE'
    }.freeze

    def default_where_scope(params)
      where_string = []
      where_hash = {}

      params.each do |key, value|
        real_key, sign_str = key.to_s.split('-', 2)
        agent_key = key.gsub(/[->.:]/, '_')

        if value.nil? || value == []
          if sign_str == 'not'
            where_string << "#{real_key} IS NOT NULL"
          elsif sign_str.nil?
            where_string << "#{real_key} IS NULL"
          else
            raise "#{key}'s value can not be nil"
          end
        elsif sign_str == 'any' # 支持 postgres array 查询
          where_string << ":#{agent_key} = ANY(#{real_key})"
          where_hash.merge! agent_key.to_sym => value
        elsif sign_str.match?(/->/) # 支持 postgres json 查询
          keys = sign_str.split('->')
          if keys.size == 1
            where_string << "#{real_key}->'#{sign_str}' = :#{agent_key}"
          elsif keys.size == 2
            where_string << "#{real_key}->'#{keys[0]}'->>'#{keys[1]}' = :#{agent_key}"
          end
          where_hash.merge! agent_key.to_sym => value
        else
          case sign_str
          when 'll'
            real_value = "#{value}%"
          when 'rl'
            real_value = "%#{value}"
          when 'like'
            real_value = "%#{value}%"
          else
            real_value = value
          end

          key_with_table = real_key.include?('.') ? real_key : "#{table_name}.#{real_key}"
          where_string << "#{key_with_table} #{PATTERN[sign_str.to_s.to_sym]} :#{agent_key}"
          where_hash.merge! agent_key.to_sym => real_value
        end
      end

      [where_string, where_hash]
    end

  end
end

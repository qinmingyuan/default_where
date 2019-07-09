# frozen_string_literal: true

module DefaultWhere
  module Or

    def or_scope(params)
      where_hash = {}

      params.each do |key, value|
        real_key = key.split('-or-')

        if column_names.include?(real_key)
          real_key = "#{table_name}.#{real_key}"
        end

        where_hash.merge! real_key => value
      end

      if where_hash.present?
        where.or(where(where_hash))
      else
        current_scope
      end
    end

    def filter_or(params)
      params.select do |k, _|
        k.include?('-or-')
      end
    end

  end
end


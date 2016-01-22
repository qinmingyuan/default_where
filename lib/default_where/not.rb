module DefaultWhere
  module Not

    def not_scope(params)
      where_hash = {}

      params.each do |key, value|
        real_key = key.sub(/-not$/, '')
        where_hash.merge! real_key.to_sym => value
      end

      where.not(where_hash)
    end

    def filter_not(params)
      params.select do |k, _|
        k.end_with?('-not')
      end
    end

  end
end


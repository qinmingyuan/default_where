module DefaultWhere
  module Not

    def not_scope(params)
      where_string = ''
      where_hash = {}

      params.each do |key, value|
        where_string << " AND #{key} = :#{key}"
        where_hash.merge! key.to_sym => value
      end

      where_string.sub!(/^ AND /, '') if where_string.start_with?(' AND ')
      condition = [where_string, where_hash]

      where.not(condition)
    end

    def filter_not(params)
      params.select do |k, _|
        k.end_with?('_not')
      end
    end

  end
end


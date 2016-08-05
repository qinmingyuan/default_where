module DefaultWhere
  module Like

    def like_scope(params)
      where_string = ''
      where_hash = {}

      params.select{ |key, _| key.end_with?('-like') }.each do |k, value|
        real_key = k.sub(/-like$/, '')
        where_string << " AND #{real_key} like :#{k}"
        where_hash.merge! k.to_sym => value
      end

      where_string.sub!(/^ AND /, '') if where_string.start_with?(' AND ')

      if where_string.present?
        condition = [where_string, where_hash]
        where(condition)
      else
        all
      end
    end

    def filter_like(params)
      params.select do |k, v|
        k =~ /o\d/ && v.end_with?('-like')
      end
    end

  end
end

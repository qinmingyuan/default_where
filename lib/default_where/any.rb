# for postgresql array search
module DefaultWhere
  module Any

    def any_scope(params)
      where_string = []
      where_hash = {}

      params.each do |key, value|
        real_key = key.sub(/-(any)$/, '')
        agent_key = key.gsub(/[-.]/, '_')

        where_string << ":#{agent_key} = ANY(#{real_key})"
        where_hash.merge! agent_key.to_sym => value
      end

      where_string = where_string.join ' AND '

      if where_string.present?
        condition = [where_string, where_hash]
        where(condition)
      else
        all
      end
    end

    def filter_any(params)
      params.select do |k, _|
        k.end_with?('-any')
      end
    end

  end
end


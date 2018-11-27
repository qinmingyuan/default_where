# for i18n jsonb support search
module DefaultWhere
  module Key
    PATTERN = ['-en', '-zh']

    def key_scope(params)
      where_string = []
      where_hash = {}

      params.each do |key, value|
        i18n_key = key[/(en|zh)$/, 1]
        real_key = key.sub(/-(en|zh)$/, '')
        agent_key = key.gsub(/[-.]/, '_')

        next unless column_names.include?(real_key)

        where_string << "#{real_key}->>'#{i18n_key}' = :#{agent_key}"

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

    def filter_key(params)
      params.select do |k, _|
        k.end_with?(*PATTERN)
      end
    end

  end
end


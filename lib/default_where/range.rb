module DefaultWhere
  module Range

    PATTERN = {
      '-gt' => '>',
      '-gte' => '>=',
      '-lt' => '<',
      '-lte' => '<='
    }

    def range_scope(params)
      where_string = ''
      where_hash = {}

      PATTERN.each do |char, sign|
        options = params.select{ |key, _| key.end_with?(char) }

        options.each do |key, value|
          exp = Regexp.new(char + '$')
          real_key = key.sub(exp, '')

          where_string << " AND #{real_key} #{sign} :#{key}"

          where_hash.merge! key.to_sym => value
        end
      end

      where_string.sub!(/^ AND /, '') if where_string.start_with?(' AND ')

      condition = [where_string, where_hash]

      where(condition)
    end

    def filter_range(params)
      params.select do |k, _|
        k.end_with?(*PATTERN.keys)
      end
    end

  end
end

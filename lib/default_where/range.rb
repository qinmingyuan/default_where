module DefaultWhere
  module Range

    PATTERN = {
      '_gt' => '>',
      '_gte' => '>=',
      '_lt' => '<',
      '_lte' => '<='
    }

    def range_scope(params, tables)
      where_string = ''
      where_hash = {}

      PATTERN.each do |pt, compare|
        options = params.select{ |key, _| key.end_with?(pt) }

        options.each do |origin_key, value|
          exp = Regexp.new(pt + '$')
          key = origin_key.sub(exp, '')
          table, _ = key.split('.')

          where_string << " AND #{key} #{compare} :#{origin_key}"

          type = tables[table].constantize.columns_hash[origin_key].type

          if type == :integer
            where_hash.merge! origin_key.to_sym => value.to_i
          else
            where_hash.merge! origin_key.to_sym => value
          end
        end
      end

      where_string.sub!(/^ AND /, '') if where_string.start_with?(' AND ')

      condition = [where_string, where_hash]

      where(condition)
    end

    def filter_range(params)
      params.select do |k, _|
        k.end_with?('_gt', '_gte', '_lt', '_lte')
      end
    end

  end
end

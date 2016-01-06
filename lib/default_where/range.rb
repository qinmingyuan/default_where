module DefaultWhere
  module Range

    PATTERN = {
      '_gt' => '>',
      '_gte' => '>=',
      '_lt' => '<',
      '_lte' => '<='
    }

    def range_scope(params)
      where_string = ''
      where_hash = {}

      PATTERN.each do |k, compare|
        gt_options = params.select { |key, _| key.end_with?(k) }

        gt_options.each do |origin_key, value|
          exp = Regexp.new(k + '$')
          key = origin_key.sub(exp, '')

          where_string << " AND #{key} #{compare} :#{origin_key}"
          if columns_hash[origin_key].type == :integer
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


  end
end

module DefaultWhere
  module Range
    PATTERN = {
      '>' => /_gt$/,
      '>=' => /_gte$/,
      '<' => /_lt$/,
      '<=' => /_lte$/
    }
    SPATTERN = {
      '_gt' => '>',
      '_gte' => '>=',
      '_lt' => '<',
      '_lte' => '<='
    }


    def range_scope(params)
      @range_string = ''
      @range_hash = {}

      range_process(params)

      @range_string.sub!(/^\sand/, '') if @range_string.start_with?(' and')

      condition = [@range_string, @range_hash]

      where(condition)
    end

    # process with table
    # gt: greater than
    # gte: greater than or equal to
    # lt: less than
    # lte: less than or equal to
    def range_process(params)
      SPATTERN.each do |k, v|
        gt_options = params.select { |key, _| key.end_with?(k) }
        range_process_compare(gt_options, v)
      end
    end

    def range_process_compare(params, compare)
      params.each do |origin_key, value|
        key = origin_key.sub(PATTERN[compare], '')

        @range_string << " and #{key} #{compare} :#{origin_key}"
        if value.to_i.to_s == value
          @range_hash.merge! origin_key.to_sym => value.to_i
        else
          @range_hash.merge! origin_key.to_sym => value
        end
      end

      params
    end

  end
end

module DefaultWhere::Order

  PATTERN = {
    '>' => /_gt$/,
    '>=' => /_gte$/,
    '<' => /_lt$/,
    '<=' => /_lte$/
  }

  def range_scope(params, options)
    @range_string = ''
    @range_hash = {}

    range_process(params, options) # process range params

    @range_string.sub!(/^\sand/, '') if @range_string.start_with?(' and')

    condition = [@range_string, @range_hash]

    where(condition)
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


  # process with table
  # gt: greater than
  # gte: greater than or equal to
  # lt: less than
  # lte: less than or equal to
  def range_process(params, options)
    options.each do |assoc, column|
      assoc_model = reflections[assoc.to_sym]
      if assoc_model
        params.select{ |k, _| k.start_with?(column.to_s) }.each do |key, _|
          params["#{assoc_model.table_name}.#{key}"] = params.delete(key)
        end
      else
        raise 'Wrong Association Name'
      end
    end

    params.each do |key, _|
      params["#{table_name}.#{key}"] = params.delete(key.to_s)
    end

    gt_options = params.select { |key, _| key.end_with?('_gt') }
    gte_options = params.select { |key, _| key.end_with?('_gte') }
    lt_options = params.select { |key, _| key.end_with?('_lt') }
    lte_options = params.select { |key, _| key.end_with?('_lte') }

    range_process_compare(gt_options, '>')
    range_process_compare(gte_options, '>=')
    range_process_compare(lt_options, '<')
    range_process_compare(lte_options, '<=')
  end

end

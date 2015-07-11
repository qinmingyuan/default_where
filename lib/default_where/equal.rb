module DefaultWhere::Equal

  def equal_scope(params, options)
    @where_string = ''
    @where_hash = {}

    params = equal_params(params, options)
    equal_process(params) # 处理相等条件的参数

    @where_string.sub!(/^\sand/, '') if @where_string.start_with?(' and')

    condition = [@where_string, @where_hash]

    where(condition)
  end

  private
  # 处理等于参数
  def equal_process(params)
    params.each do |key, value|
      origin_key = key.split('.').last

      @where_string << " and #{key} = :#{origin_key}"
      @where_hash.merge! origin_key.to_sym => value
    end
  end

  # 带表格的参数
  def equal_params(params, options)
    options.each do |assoc, column|
      assoc_model = reflections[assoc.to_sym]
      value = params.delete(column.to_s)
      if assoc_model && value
        params["#{assoc_model.table_name}.#{column}"] = value
      elsif assoc_model.blank?
        raise 'Wrong Association Name'
      end
    end

    # since 1.9 is using lazy iteration
    params.to_a.each do |key, _|
      if column_names.include?(key)
        params["#{table_name}.#{key}"] = params.delete(key.to_s)
      elsif !key.include?('.')
        params.delete(key.to_s)
      end
    end

    params
  end

end

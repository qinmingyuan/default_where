module QueryScope

  def query_scope(params)
    params ||= {}
    params = filter_params(params)

    @where_string = ''
    @where_hash = {}

    # 先检查是否有范围查询的参数
    range_options = range_params(params)
    range_process(range_options)

    # 处理相等条件的参数
    range_options.map { |i| i.keys }.flatten.each do |k|
      params.delete(k)
    end
    equal_process(params)

    @where_string.sub!(/^\sand/, '') if @where_string.start_with?(' and')

    condition = [@where_string, @where_hash]
    where(condition)
  end

  private
  # 清理为空值的内容
  def filter_params(params)
    params.select { |_, v| v.present? }
  end

  # 生成范围的条件
  # gt: 大于
  # gte: 大于等于
  # lt: 小于
  # lte: 小于等于
  def range_params(params)
    gt_options = params.select { |k, _| k.end_with?('_gt') }
    gte_options = params.select { |k, _| k.end_with?('_gte') }
    lt_options = params.select { |k, _| k.end_with?('_lt') }
    lte_options = params.select { |k, _| k.end_with?('_lte') }

    [gt_options, gte_options, lt_options, lte_options]
  end


  # 处理范围参数
  def range_process(options)

    if options[0].present?
      options[0].each do |origin_k, v|
        k = origin_k.sub(/_gt$/, '')

        @where_string << " and #{table_name}.#{k} > :#{origin_k}"
        @where_hash.merge! origin_k.to_sym => v
      end
    end

    if options[1].present?
      options[1].each do |origin_k, v|
        k = origin_k.sub(/_gte$/, '')

        @where_string << " and #{table_name}.#{k} >= :#{origin_k}"
        @where_hash.merge! origin_k.to_sym => v
      end
    end

    if options[2].present?
      options[2].each do |origin_k, v|
        k = origin_k.sub(/_lt$/, '')

        @where_string << " and #{table_name}.#{k} < :#{origin_k}"
        @where_hash.merge! origin_k.to_sym => v
      end
    end

    if options[3].present?
      options[3].each do |origin_k, v|
        k = origin_k.sub(/_lte$/, '')

        @where_string << " and #{table_name}.#{k} <= :#{origin_k}"
        @where_hash.merge! origin_k.to_sym => v
      end
    end

  end

  # 处理等于参数
  def equal_process(options)
    options.each do |k, v|
      @where_string << " and #{table_name}.#{k} = :#{k}"
      @where_hash.merge! k.to_sym => v
    end
  end

end

ActiveRecord::Base.extend QueryScope

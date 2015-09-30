module DefaultWhere
  module Equal

    def equal_scope(params, options)
      @where_string = ''
      @where_hash = {}

      params = equal_params(params, options)
      equal_process(params)

      @where_string.sub!(/^\sand/, '') if @where_string.start_with?(' and')

      condition = [@where_string, @where_hash]

      where(condition)
    end

    private
    # process equal params
    def equal_process(params)
      params.each do |key, value|
        origin_key = key.split('.').last

        @where_string << " and #{key} = :#{origin_key}"
        if value.to_i.to_s == value
          @where_hash.merge! origin_key.to_sym => value.to_i
        elsif 'true' == value
          @where_hash.merge! origin_key.to_sym => true
        elsif 'false' == value
          @where_hash.merge! origin_key.to_sym => false
        else
          @where_hash.merge! origin_key.to_sym => value
        end
      end
    end

    # params with table
    def equal_params(params, options)


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
end

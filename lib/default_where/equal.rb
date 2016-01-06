module DefaultWhere
  module Equal

    def equal_scope(params)
      @where_string = ''
      @where_hash = {}

      equal_process(params)

      @where_string.sub!(/^\sand\s/, '') if @where_string.start_with?(' and')

      condition = [@where_string, @where_hash]

      where(*condition)
    end

    private
    def equal_process(params)
      params.each do |key, value|
        origin_key = key.split('.').last

        @where_string << " and #{key} = :#{origin_key}"

        if columns_hash[origin_key].type == :integer
          @where_hash.merge! origin_key.to_sym => value.to_i
        elsif columns_hash[origin_key].type == :boolean
          @where_hash.merge! origin_key.to_sym => value.to_bool
        else
          @where_hash.merge! origin_key.to_sym => value
        end
      end
    end

  end
end


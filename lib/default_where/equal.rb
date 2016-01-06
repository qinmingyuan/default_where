module DefaultWhere
  module Equal

    def equal_scope(params)
      where_string = ''
      where_hash = {}



      params.each do |key, value|
        table, origin_key = key.split('.')

        where_string << " AND #{key} = :#{origin_key}"

        type = table.classify.constantize.columns_hash[origin_key].type

        if type == :integer
          where_hash.merge! origin_key.to_sym => value.to_i
        elsif type == :boolean
          where_hash.merge! origin_key.to_sym => to_bool(value)
        else
          where_hash.merge! origin_key.to_sym => value
        end
      end

      where_string.sub!(/^ AND /, '') if where_string.start_with?(' AND ')
      condition = [where_string, where_hash]

      where(condition)
    end

    def to_bool(value)
      value == 'true' ? true : false
    end

  end
end


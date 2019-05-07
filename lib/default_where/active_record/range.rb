module DefaultWhere
  module ActiveRecord
    module Range
      PATTERN = {
        '-gt' => '>',
        '-gte' => '>=',
        '-lt' => '<',
        '-lte' => '<='
      }
  
      def range_scope(params)
        where_string = []
        where_hash = {}
  
        params.each do |key, value|
          exp = /-(gt|gte|lt|lte)$/
          real_key = key.sub(exp, '')
          sign_str = key.match(exp).to_s
          agent_key = key.gsub(/[-.]/, '_')
  
          if column_names.include?(real_key)
            real_key = "#{table_name}.#{real_key}"
          end
  
          where_string << "#{real_key} #{PATTERN[sign_str]} :#{agent_key}"
  
          where_hash.merge! agent_key.to_sym => value
        end
  
        where_string = where_string.join ' AND '
  
        if where_string.present?
          condition = [where_string, where_hash]
          where(condition)
        else
          all
        end
      end
  
      def filter_range(params)
        params.select do |k, _|
          k.end_with?(*PATTERN.keys)
        end
      end
      
    end
  end
end

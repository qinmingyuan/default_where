# frozen_string_literal: true

module DefaultWhere
  module ActiveRecord
  
    def default_where_params(params = {}, options = {})
      refs = []
      tables = []
      final_params = {}
    
      params.each do |key, value|
        # strip, if assign key to false, will not works
        strip = options.fetch(:strip, {}).fetch(key, STRIP)
        value = value.strip if value.is_a?(String) && strip
      
        # reject
        if options.key?(:reject)
          reject = options.fetch(:reject, {}).fetch(key, REJECT)
          if reject == nil
            reject = [nil]
          elsif reject == []
            reject = [[]]
          else
            reject = Array(reject)
          end
        else
          allow = options.fetch(:allow, {}).fetch(key, [])
          if allow == nil
            allow = [nil]
          else
            allow = Array(allow)
          end
          reject = REJECT - allow
        end
        next if reject.include?(value)
      
        items = key.to_s.split('.')
        column = items[-1]
        real_column = column.split(/[-\/]/)[0]
      
        if items.size == 1
          next unless column_names.include?(real_column)
          table = table_name
        else
          prefix = items[0]
          ref = reflections[prefix]
        
          # 检查 prefix 是否为关联关系的名称
          if ref && !ref.polymorphic?
            table = ref.table_name
            # 检查 prefix 是否为表名，且表中存在 real_column 字段
          elsif connection.data_sources.include?(prefix) && connection.column_exists?(prefix, real_column)
            possible_refs = reflections.select { |_, v| v.table_name == prefix }
            if possible_refs.size < 1
              ref = nil
            elsif possible_refs.size == 1
              ref = possible_refs[0]
            else
              raise "#{key} makes confused, please use reflection name!"
            end
          
            table = prefix
          else
            next
          end
        
          if ref && !ref.klass.column_names.include?(real_column)
            next
          end
        
          if ref && !refs.include?(ref.name)
            refs << ref.name
          end
        
          unless tables.include?(table)
            tables << table
          end
        end
      
        final_params["#{table}.#{column}"] = value
      end
    
      [final_params, refs, tables]
    end

  end
end

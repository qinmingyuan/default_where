# frozen_string_literal: true

module DefaultWhere
  module Group

    # {
    #   select: 'sum(total_amount)',
    #   select: {
    #     a: 'sum(total_amount)',
    #     b: 'sum()'
    #   }
    # }
    #  group: 'date(created_at)',
    def default_group(*group, select:)
      if select.respond_to?(:to_hash)
        selected = select.map do |k, v|
          "#{v} AS #{k}"
        end
      else
        selected = Array(select)
      end
      
      unscoped.select(*selected, *group).group(*select.values)
    end
    
  end
end

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
      if select.is_a?(String)
        select = Array(select)
      elsif select.respond_to?(:to_hash)
        select = select.map do |k, v|
          "#{v} AS #{k}"
        end
      end
      unscoped.select(*group, *select).group(*group)
    end
    
  end
end

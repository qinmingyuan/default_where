module DefaultWhere
  module ActiveModel
  
    def human_attribute_name(attribute, options = {})
      if attribute.to_s.end_with?('-like')
        attribute = attribute.to_s.sub('-like', '')
      end
      super
    end
  
  end
end


ActiveSupport.on_load :active_record do
  extend DefaultWhere::ActiveModel
end

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

        #if value.to_i.to_s == value
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

class String
  def to_bool
    return true   if self == true   || self =~ (/(true|t|yes|y|1)$/i)
    return false  if self == false  || self.blank? || self =~ (/(false|f|no|n|0)$/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
  end
end
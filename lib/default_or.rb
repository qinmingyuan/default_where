module DefaultWhere::DefaultOr

  def default_or(hash)
    return all if hash.blank?

    keys = hash.keys
    query = where(keys[0] => hash[keys[0]])

    keys[1..-1].each do |key|
      query = query.or(where(key => hash[key]))
    end

    query
  end

end

ActiveRecord::Base.extend TheRole::Owner

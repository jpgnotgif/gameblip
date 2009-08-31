module HashExtras
  def self.underscorize_and_symbolize_all_keys!(hash)
    return hash unless is_valid_hash?(hash)
    hash.each do |k,v|
      underscorize_and_symbolize_all_keys!(v) if is_valid_hash?(v)
      hash.delete(k)
      hash[k.to_s.underscore.to_sym] = v
    end 
    return hash
  end

  def self.is_valid_hash?(hash)
    return false if hash.nil? || !hash.is_a?(Hash) || hash.empty?
    return true
  end
end

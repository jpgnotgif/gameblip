# @author:  josephpgutierrez
# @date:    07.14.2009
# @note:    This module contains methods used to manipulate hashes. The ideal
# implementation would be to extend the hash module through activesupport
# and add both a destructive and non-destructive method to this module.

module HashExtras
  def self.symbolize_all_keys!(hash)
    return hash if hash.empty? || !hash.is_a?(Hash)
    hash.symbolize_keys!
    hash.each { |k, v| symbolize_all_keys!(v) if v.is_a?(Hash) }
  end
end

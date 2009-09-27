Factory.define :playstation_identity do |f|
  xml_data = File.open(File.join("spec/files/xml/psn/geek_at_home", "profile.xml"), "r") { |file| file.read }
  hash_data = Hash.from_xml(xml_data)
  data = HashExtras.underscorize_and_symbolize_all_keys!(hash_data)
  f.name data[:xml][:body][:user][:psnid]
  f.avatar_url data[:xml][:body][:category][:item].first["imgurl"]
  f.online data[:xml][:body][:category][:item].first["onlinestate"].downcase == "online" ? true : false
  f.location "San Francisco, CA. USA"
end

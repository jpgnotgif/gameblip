Factory.define :gamer_identity do |f|
  xml_file_data = File.open(File.join(RAILS_ROOT, "spec/files/xml/xbox_live/", "jpgnotgif.xml" ), "r") { |file| file.read }
  hash_data = Hash.from_xml(xml_file_data)
  data = HashExtras.underscorize_and_symbolize_all_keys!(hash_data)
  f.name data[:xbox_info][:gamertag]
  f.avatar_url data[:xbox_info][:tile_url]
  f.online data[:xbox_info][:presence_info][:online]
  f.last_online_at Time.parse(data[:xbox_info][:presence_info][:last_seen])
  f.location "San Francisco, CA. USA"
end

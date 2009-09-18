Factory.define :gamer_identity do |f|
  xml_file_data = File.open(File.join(RAILS_ROOT, "spec/files/xml/xbox_live/", "jpgnotgif.xml" ), "r") { |file| file.read }
  hash_data = HashExtras.underscorize_and_symbolize_all_keys!(Hash.from_xml(xml_file_data))

  f.name hash_data[:xbox_info][:gamertag]
  f.avatar_url hash_data[:xbox_info][:tile_url]
  f.online hash_data[:xbox_info][:presence_info][:online]
  f.last_online_at Time.parse(hash_data[:xbox_info][:presence_info][:last_seen])
end

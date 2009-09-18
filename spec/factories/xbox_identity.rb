Factory.define :xbox_identity do |f|    
  xml_file_data = File.open(File.join(RAILS_ROOT, "spec/files/xml/xbox_live/jpgnotgif.xml"), "r") { |file| file.read }
  hash_data = HashExtras.underscorize_and_symbolize_all_keys!(Hash.from_xml(xml_file_data))
  f.account_status hash_data[:xbox_info][:account_status]
  f.gamerscore hash_data[:xbox_info][:gamer_score]
  f.reputation hash_data[:xbox_info][:reputation]
  f.motto "Do work!"
end

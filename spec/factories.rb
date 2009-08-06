# @author:  josephpgutierrez
# @date:    06.13.2009
# @note:    Factories file

Factory.define(:user) do |f|
  f.login "captain_america"
  f.email "captain_america@shield.com"
  f.password "captain_america"
  f.password_confirmation "captain_america"
end

Factory.define(:xbox_console_user) do |f|    
  data = HashExtras.symbolize_all_keys!(Hash.from_xml(File.open(File.join(RAILS_ROOT, "spec/files/xml/xbox_live/jpgnotgif.xml"), "r") { |file| file.read }))
  f.gamertag data[:xbox_info][:gamertag]
  f.account_status data[:xbox_info][:account_status]
  f.status data[:xbox_info][:presence_info][:status_text]
  f.gamerscore data[:xbox_info][:gamer_score]
  f.avatar_url data[:xbox_info][:tile_url]
  f.location data[:xbox_info][:location]
  f.country data[:xbox_info][:country]
  f.reputation_url data[:xbox_info][:reputation_image_url]
  f.zone data[:xbox_info][:zone]
  f.last_seen_at Time.parse(data[:xbox_info][:presence_info][:last_seen])
  f.online data[:xbox_info][:presence_info][:online]
end

Factory.define(:playstation_console_user) do |f|
  data = HashExtras.symbolize_all_keys!(Hash.from_xml(File.open(File.join(RAILS_ROOT, "spec/files/xml/psn/geek_at_home/profile.xml"), "r") { |file| file.read}))
  f.psn_id data[:xml][:body][:user][:psnid]
  f.rank data[:xml][:body][:category][:item].first["ranking"]
  f.avatar_url data[:xml][:body][:category][:item].first["imgurl"]
  
  month, day, year = data[:xml][:body][:category][:item].first["regdate"].split.first.split("-")
  time, day_period = data[:xml][:body][:category][:item].first["regdate"].split[1], data[:xml][:body][:category][:item].first["regdate"].split.last
  f.registered_at Time.parse("#{year}-#{month}-#{day} #{time}#{day_period}") 
  f.online data[:xml][:body][:category][:item].last["onlinestate"].downcase == "online"
  f.country "US" 
end

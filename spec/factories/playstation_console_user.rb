 Factory.define(:playstation_console_user) do |f|
   data = HashExtras.underscorize_and_symbolize_all_keys!(Hash.from_xml(File.open(File.join(RAILS_ROOT, "spec/files/xml/psn/geek_at_home/profile.xml"), "r") { |file| file.    read}))
   f.psn_id data[:xml][:body][:user][:psnid]
   f.rank data[:xml][:body][:category][:item].first["ranking"]
   f.avatar_url data[:xml][:body][:category][:item].first["imgurl"]
  
   month, day, year = data[:xml][:body][:category][:item].first["regdate"].split.first.split("-")
   time, day_period = data[:xml][:body][:category][:item].first["regdate"].split[1], data[:xml][:body][:category][:item].first["regdate"].split.last
   f.registered_at Time.parse("#{year}-#{month}-#{day} #{time}#{day_period}")
   f.online data[:xml][:body][:category][:item].last["onlinestate"].downcase == "online"
   f.country "US"
 38 end

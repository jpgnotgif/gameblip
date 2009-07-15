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
  data = HashExtras.symbolize_all_keys!(Hash.from_xml(File.open(File.join(RAILS_ROOT, "test/files/xml/xbox.xml"), "r") { |file| file.read }))
  f.gamertag data[:xbox_info][:gamertag]
end

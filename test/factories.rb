# @author:  josephpgutierrez
# @date:    06.13.2009
# @note:    Factories file

Factory.define(:user) do |f|
  f.login "captain_america"
  f.email "captain_america@shield.com"
  f.password "captain_america"
  f.password_confirmation "captain_america"
end

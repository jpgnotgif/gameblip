module XboxConsoleUsersHelper
  def pretty_time(time)
    return time.strftime("%I:%M%p - %A, %B %d, %Y")
  end
end

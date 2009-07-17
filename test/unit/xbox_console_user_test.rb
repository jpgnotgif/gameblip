require File.dirname(__FILE__) + '/../test_helper'

class XboxConsoleUserTest < ActiveSupport::TestCase
  def setup
    @user              = users(:josephpgutierrez)
    @xbox_console_user = Factory.build(:xbox_console_user, {:user => @user})
    @xml               = File.open(File.join(RAILS_ROOT, "test/files/xml/xbox_live", "foo.xml"), "r") { |f| f.read }
  end

  def test_should_save
    assert_difference ["@user.xbox_console_users.count", "XboxConsoleUser.count"] do
      Net::HTTP.expects(:get).with(URI.parse(AppConfig.xbox_api.url + "#{@xbox_console_user.gamertag}")).returns(@xml)
      assert @xbox_console_user.save, "Errors :: #{@xbox_console_user.errors.full_messages.to_sentence.inspect}"
      assert_equal @user.id, @xbox_console_user.user_id
      assert_not_nil @xbox_console_user.account_status
      assert_not_nil @xbox_console_user.status
      assert_not_nil @xbox_console_user.gamerscore
      assert_not_nil @xbox_console_user.avatar_url
      assert_not_nil @xbox_console_user.zone
      assert_not_nil @xbox_console_user.last_seen_at
    end
  end

  def test_validates_presence_of_gamertag
    @xbox_console_user.gamertag = nil
    assert_no_difference "XboxConsoleUser.count" do
      assert_equal false, @xbox_console_user.save
      assert @xbox_console_user.errors.on(:gamertag)
    end
  end

  def test_validates_presence_of_user_id
    @xbox_console_user.user_id = nil
    assert_no_difference ["@user.xbox_console_users.count", "XboxConsoleUser.count"] do
      Net::HTTP.expects(:get).with(URI.parse(AppConfig.xbox_api.url + "#{@xbox_console_user.gamertag}")).returns(@xml)
      assert_equal false, @xbox_console_user.save
      assert @xbox_console_user.errors.full_messages.include?("User must be associated with an Xbox360 gamertag"), "Errors :: #{@xbox_console_user.errors.full_messages.to_sentence.inspect}"
    end
  end

end

require File.dirname(__FILE__) + '/../test_helper'

class XboxConsoleUserTest < ActiveSupport::TestCase
  def setup
    @xbox_console_user = Factory.build(:xbox_console_user)
    @xml               = File.open(File.join(RAILS_ROOT, "test/files/xml", "xbox.xml"), "r") { |f| f.read }
  end

  def test_should_save
    assert_difference "XboxConsoleUser.count" do
      Net::HTTP.expects(:get).with(AppConfig.xbox_api.url + "#{@xbox_console_user.gamertag}").returns(@xml)
      assert @xbox_console_user.save, "Errors :: #{@xbox_console_user.errors.full_messages.to_sentence.inspect}"
    end
  end

  def test_validates_presence_of_gamertag
    @xbox_console_user.gamertag = nil
    assert_no_difference "XboxConsoleUser.count" do
      assert_equal false, @xbox_console_user.save
      assert @xbox_console_user.errors.on(:gamertag)
    end
  end

end

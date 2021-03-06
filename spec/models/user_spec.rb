require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  describe "with identities" do
    it "should fetch xbox identities" do
      user = setup_user_with_xbox_identity
      user.should respond_to(:xbox_identities)
      user.xbox_identities.count.should == 1
    end

    it "should fetch playstation identities" do
      user = setup_user_with_playstation_identity
      user.should respond_to(:playstation_identities)
      user.playstation_identities.count.should == 1
    end
  end

  describe 'being created' do
    before do
      @user = nil
      @creating_user = lambda do
        @user = create_user
        violated "#{@user.errors.full_messages.to_sentence}" if @user.new_record?
      end
      @emails = ActionMailer::Base.deliveries
      @emails.clear
    end

    it 'increments User#count' do
      @creating_user.should change(User, :count).by(1)
      @emails.size.should == 1
    end
  end

  # Validations
  it 'requires login' do
    lambda do
      u = create_user(:login => nil)
      u.errors.on(:login).should_not be_nil
    end.should_not change(User, :count)
  end

  describe 'allows legitimate logins:' do
    ['123', '1234567890_234567890_234567890_234567890',
     'hello.-_there@funnychar.com'].each do |login_str|
      it "'#{login_str}'" do
        lambda do
          u = create_user(:login => login_str)
          u.errors.on(:login).should     be_nil
        end.should change(User, :count).by(1)
      end
    end
  end
  describe 'disallows illegitimate logins:' do
    ['12', '1234567890_234567890_234567890_234567890_', "tab\t", "newline\n",
     "Iñtërnâtiônàlizætiøn hasn't happened to ruby 1.8 yet",
     'semicolon;', 'quote"', 'tick\'', 'backtick`', 'percent%', 'plus+', 'space '].each do |login_str|
      it "'#{login_str}'" do
        lambda do
          u = create_user(:login => login_str)
          u.errors.on(:login).should_not be_nil
        end.should_not change(User, :count)
      end
    end
  end

  it 'requires password' do
    lambda do
      u = create_user(:password => nil)
      u.errors.on(:password).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'requires password confirmation' do
    lambda do
      u = create_user(:password_confirmation => nil)
      u.errors.on(:password_confirmation).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'requires email' do
    lambda do
      u = create_user(:email => nil)
      u.errors.on(:email).should_not be_nil
    end.should_not change(User, :count)
  end

  describe 'allows legitimate emails:' do
    ['foo@bar.com', 'foo@newskool-tld.museum', 'foo@twoletter-tld.de', 'foo@nonexistant-tld.qq',
     'r@a.wk', '1234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890@gmail.com',
     'hello.-_there@funnychar.com', 'uucp%addr@gmail.com', 'hello+routing-str@gmail.com',
     'domain@can.haz.many.sub.doma.in', 'student.name@university.edu'
    ].each do |email_str|
      it "'#{email_str}'" do
        lambda do
          u = create_user(:email => email_str)
          u.errors.on(:email).should     be_nil
        end.should change(User, :count).by(1)
      end
    end
  end
  describe 'disallows illegitimate emails' do
    ['!!@nobadchars.com', 'foo@no-rep-dots..com', 'foo@badtld.xxx', 'foo@toolongtld.abcdefg',
     'Iñtërnâtiônàlizætiøn@hasnt.happened.to.email', 'need.domain.and.tld@de', "tab\t", "newline\n",
     'r@.wk', '1234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890@gmail2.com',
     # these are technically allowed but not seen in practice:
     'uucp!addr@gmail.com', 'semicolon;@gmail.com', 'quote"@gmail.com', 'tick\'@gmail.com', 'backtick`@gmail.com', 'space @gmail.com', 'bracket<@gmail.com', 'bracket>@gmail.com'
    ].each do |email_str|
      it "'#{email_str}'" do
        lambda do
          u = create_user(:email => email_str)
          u.errors.on(:email).should_not be_nil
        end.should_not change(User, :count)
      end
    end
  end

  describe 'allows legitimate names:' do
    ['Andre The Giant (7\'4", 520 lb.) -- has a posse',
     '', '1234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890',
    ].each do |name_str|
      it "'#{name_str}'" do
        lambda do
          u = create_user(:name => name_str)
          u.errors.on(:name).should     be_nil
        end.should change(User, :count).by(1)
      end
    end
  end
  describe "disallows illegitimate names" do
    ["tab\t", "newline\n",
     '1234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_',
     ].each do |name_str|
      it "'#{name_str}'" do
        lambda do
          u = create_user(:name => name_str)
          u.errors.on(:name).should_not be_nil
        end.should_not change(User, :count)
      end
    end
  end

  it 'resets password' do
    users(:josephpgutierrez).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    User.authenticate('josephpgutierrez', 'new password').should == users(:josephpgutierrez)
  end

  it 'does not rehash password' do
    users(:josephpgutierrez).update_attributes(:login => 'quentin2')
    User.authenticate('quentin2', 'josephpgutierrez').should == users(:josephpgutierrez)
  end

  #
  # Authentication
  #

  it 'authenticates user' do
    User.authenticate("josephpgutierrez", "josephpgutierrez").should == users(:josephpgutierrez)
  end

  it "doesn't authenticate user with bad password" do
    User.authenticate('quentin', 'invalid_password').should be_nil
  end

 if REST_AUTH_SITE_KEY.blank?
   # old-school passwords
   it "authenticates a user against a hard-coded old-style password" do
     User.authenticate('old_password_holder', 'test').should == users(:old_password_holder)
   end
 else
   it "doesn't authenticate a user against a hard-coded old-style password" do
     User.authenticate('old_password_holder', 'test').should be_nil
   end

   # New installs should bump this up and set REST_AUTH_DIGEST_STRETCHES to give a 10ms encrypt time or so
   desired_encryption_expensiveness_ms = 0.1
   it "takes longer than #{desired_encryption_expensiveness_ms}ms to encrypt a password" do
     test_reps = 100
     start_time = Time.now; test_reps.times{ User.authenticate('quentin', 'monkey'+rand.to_s) }; end_time   = Time.now
     auth_time_ms = 1000 * (end_time - start_time)/test_reps
     auth_time_ms.should > desired_encryption_expensiveness_ms
   end
 end

  #
  # Authentication
  #

  it 'sets remember token' do
    users(:josephpgutierrez).remember_me
    users(:josephpgutierrez).remember_token.should_not be_nil
    users(:josephpgutierrez).remember_token_expires_at.should_not be_nil
  end

  it 'unsets remember token' do
    users(:josephpgutierrez).remember_me
    users(:josephpgutierrez).remember_token.should_not be_nil
    users(:josephpgutierrez).forget_me
    users(:josephpgutierrez).remember_token.should be_nil
  end

  it 'remembers me for one week' do
    before = 1.week.from_now.utc
    users(:josephpgutierrez).remember_me_for 1.week
    after = 1.week.from_now.utc
    users(:josephpgutierrez).remember_token.should_not be_nil
    users(:josephpgutierrez).remember_token_expires_at.should_not be_nil
    users(:josephpgutierrez).remember_token_expires_at.between?(before, after).should be_true
  end

  it 'remembers me until one week' do
    time = 1.week.from_now.utc
    users(:josephpgutierrez).remember_me_until time
    users(:josephpgutierrez).remember_token.should_not be_nil
    users(:josephpgutierrez).remember_token_expires_at.should_not be_nil
    users(:josephpgutierrez).remember_token_expires_at.should == time
  end

  it 'remembers me default two weeks' do
    before = 2.weeks.from_now.utc
    users(:josephpgutierrez).remember_me
    after = 2.weeks.from_now.utc
    users(:josephpgutierrez).remember_token.should_not be_nil
    users(:josephpgutierrez).remember_token_expires_at.should_not be_nil
    users(:josephpgutierrez).remember_token_expires_at.between?(before, after).should be_true
  end

protected
  def create_user(options = {})
    record = User.new({ :login => 'quire', :email => 'quire@example.com', :password => 'quire69', :password_confirmation => 'quire69' }.merge(options))
    record.save
    record
  end

  def setup_user_with_xbox_identity
    valid_xml = File.open(File.join(RAILS_ROOT, "spec/files/xml/xbox_live", "jpgnotgif.xml"), "r") { |f| f.read }
    url = AppConfig.instance_variable_get(:@config).xbox_api.url
    gamer_identity_attributes = Factory.attributes_for(:gamer_identity)

    Net::HTTP.expects(:get).at_least_once.returns(valid_xml)
    xbox_identity = Factory.create(:xbox_identity, gamer_identity_attributes)
    return xbox_identity.user
  end

  def setup_user_with_playstation_identity
    valid_xml = File.open(File.join(RAILS_ROOT, "spec/files/xml/psn/geek_at_home/complete.xml"), "r") { |file| file.read }
    url = AppConfig.instance_variable_get(:@config).psn_api.url
    Net::HTTP.expects(:get).returns(valid_xml)
  
    gamer_identity_attributes = Factory.attributes_for(:gamer_identity)
    playstation_identity = Factory.create(:playstation_identity, gamer_identity_attributes)
    return playstation_identity.user
  end

end

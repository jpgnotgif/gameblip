require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GamerIdentity do
  before :each do
    @user = users(:josephpgutierrez)
    @category = categories(:xbox360_underground)
    @xbox_identity_attributes = Factory.attributes_for(:xbox_identity).merge(:user_id => @user.id, :category_id => @category.id)
    @gamer_identity = Factory.build(:gamer_identity, @xbox_identity_attributes)
    @gamer_identity["type"] = XboxIdentity.name
  end

  it "should create identity" do
    @gamer_identity.save.should be_true
    GamerIdentity.should have(1).record    
  end

  it "should require valid associated user" do
    @gamer_identity.user_id = nil
    @gamer_identity.save.should be_false
    @gamer_identity.should have(1).error_on(:user_id)
    GamerIdentity.should have(:no).records
  end

  it "should require valid type" do
    @gamer_identity.type = nil
    @gamer_identity.save.should be_false
    @gamer_identity.should have(1).error_on(:type)
    GamerIdentity.should have(:no).records
  end

  it "should require name" do
    @gamer_identity.name = nil
    @gamer_identity.save.should be_false
    @gamer_identity.should have(1).error_on(:name)
    GamerIdentity.should have(:no).records
  end

  it "should require valid avatar url" do
    @gamer_identity.avatar_url = nil
    @gamer_identity.save.should be_false
    @gamer_identity.should have(1).error_on(:avatar_url)
    GamerIdentity.should have(:no).records
  end

  it "should respond to invoke_api" do
    @gamer_identity.should respond_to(:invoke_api)
  end

  it "should respond to build_attributes" do
    @gamer_identity.should respond_to(:build_attributes)
  end

end

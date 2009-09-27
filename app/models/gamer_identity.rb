class GamerIdentity < ActiveRecord::Base
  attr_accessor :api_result
  belongs_to :user
  has_many :activities, :as => :avatar

  validates_presence_of :user_id, :message => "must be associated with a gamer identity"  
  validates_inclusion_of :type, :in => ["XboxIdentity", "PlaystationIdentity"]
  validates_presence_of :name, :avatar_url

  def invoke_api
    api_result
  end

  def build_attributes
  end
end

class XboxConsoleUser < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :gamertag
end

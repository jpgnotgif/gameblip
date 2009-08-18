class Activity < ActiveRecord::Base
  belongs_to :avatar, :polymorphic => true
  validate_on_create :valid_avatar?
  validates_presence_of :description
  validates_length_of :description, :maximum => 180

  private
  def valid_avatar?
    unless XboxConsoleUser.find_by_id(self.avatar_id) || PlaystationConsoleUser.find_by_id(self.avatar_id)
      self.errors.add(:avatar, "must be associated with an activity")
    end
    return self.errors.any?
  end
end


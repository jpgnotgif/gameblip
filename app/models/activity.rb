class Activity < ActiveRecord::Base
  belongs_to :avatar, :polymorphic => true
  validate_on_create :valid_avatar?
  validates_presence_of :description
  validates_length_of :description, :maximum => 180

  before_create { |record| record.avatar = eval(record.avatar_type).find_by_id(record.avatar_id) }

  named_scope :recent, lambda { |*args| {:conditions => ["created_at >= ?", args.first || 4.days.ago] } } 

  private
  # Acceptables avatar types include XboxConsoleUser and PlaystationConsoleUser. 
  def valid_avatar?
    begin
      if eval(self.avatar_type)
        if eval(self.avatar_type).find_by_id(self.avatar_id)
          return true
        end
      end
    rescue Exception => e
      logger.info(e.message)
    end
    self.errors.add(:avatar, "must be associated with an activity")
    return false
  end
end


class XboxConsoleUser < ActiveRecord::Base
  attr_accessor :api_result
  belongs_to :user
  validates_presence_of :gamertag
  validate_on_create :valid_identity?

  after_validation_on_create :build_attributes

  protected
  def valid_identity?
    valid_account_statuses = ["gold", "silver"]
    begin
      self.api_result = HashExtras.symbolize_all_keys!(Hash.from_xml(Net::HTTP.get(URI.parse(AppConfig.xbox_api.url + self.gamertag))))
      unless valid_account_statuses.include?(self.api_result[:xbox_info][:account_status].downcase)
        self.errors.add(:gamertag, "was not found, Please try again.")
        return false
      end
    rescue Exception => e
      logger.info("Exception: #{e.message}")
      self.errors.add_to_base("An error in the system occurred. Please try again later.")
      return false
    end
    return true
  end

  def build_attributes
    return false if self.errors.any?
    self.account_status = self.api_result[:xbox_info][:account_status]
    self.status = self.api_result[:xbox_info][:presence_info][:status_text]
    self.gamerscore = self.api_result[:xbox_info][:gamer_score]
    self.avatar_url = self.api_result[:xbox_info][:tile_url]
    self.location = self.api_result[:xbox_info][:location]
    self.country = self.api_result[:xbox_info][:country]
    self.reputation_url = self.api_result[:xbox_info][:reputation_image_url]
    self.zone = self.api_result[:xbox_info][:zone]
    self.last_seen_at = Time.parse(self.api_result[:xbox_info][:presence_info][:last_seen])
    self.online = self.api_result[:xbox_info][:presence_info][:online]
  end
end

class PlaystationConsoleUser < ActiveRecord::Base
  attr_accessor :profile_api_result
  belongs_to :user
  validates_presence_of :psn_id
  validates_presence_of :user_id, :message => "must be associated with a PSN ID"
  validate_on_create :valid_identity?

  after_validation_on_create :build_attributes

  private
  def valid_identity?
    return false if self.errors.any?
    begin
      self.profile_api_result = HashExtras.symbolize_all_keys!(Hash.from_xml(Net::HTTP.get(URI.parse(AppConfig.psn_api.url + self.psn_id + AppConfig.psn_api.profile))))
      unless self.profile_api_result[:xml][:body][:category][:item]
        self.errors.add(:psn_id, "was not found. Please ensure that the id is correct")
        return false
      end
    rescue Exception => e
      logger.info "Exception: #{e.message}"
      self.errors.add_to_base("An error occurred in the system. Please try again later")
      return false
    end
    return true
  end

  def build_attributes
    return false if self.errors.any?
    self.rank = self.profile_api_result[:xml][:body][:category][:item].first["ranking"]
    self.avatar_url = self.profile_api_result[:xml][:body][:category][:item].first["imgurl"]
    self.online = self.profile_api_result[:xml][:body][:category][:item].last["onlinestate"].downcase == "online"
    self.country = "US"
    month, day, year = self.profile_api_result[:xml][:body][:category][:item].first["regdate"].split.first.split("-")
    time, day_period = self.profile_api_result[:xml][:body][:category][:item].first["regdate"].split[1], self.profile_api_result[:xml][:body][:category][:item].first["regdate"].split.last
    self.registered_at = Time.parse("#{year}-#{month}-#{day} #{time}#{day_period}")
  end
end

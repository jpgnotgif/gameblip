class XboxIdentity < GamerIdentity
  attr_accessor :api_result, :gamertag
  belongs_to :user
  has_many :activities, :as => :avatar
  validates_presence_of :user_id, :message => "must be associated with an Xbox360 gamertag"
  validate_on_create :valid_identity?

  after_validation_on_create :build_attributes

  private
  def invoke_api
    begin
      xml_api_result = Net::HTTP.get(URI.parse(AppConfig.xbox_api.url + self.name))
      hash_api_result = Hash.from_xml(xml_api_result)
      api_result = HashExtras.underscorize_and_symbolize_all_keys!(hash_api_result)
      logger.info(api_result[:xbox_info].inspect)
    rescue Exception => e
      logger.info("Exception: #{e.message}\n#{e.backtrace.join("\n")}")
      self.errors.add_to_base("An error in the system occurred. Please try again later.")
    end
    return api_result
  end

  def valid_identity?
    self.api_result = invoke_api
    return false if self.errors.any?
    valid_account_statuses = ["gold", "silver"]
    unless valid_account_statuses.include?(self.api_result[:xbox_info][:account_status].downcase)
      self.errors.add(:gamertag, "was not found, Please try again.")
      return false
    end
    return true
  end

  def build_attributes
    return false if self.errors.any?
    self.category_id = Category.find_or_create_by_name(self.api_result[:xbox_info][:zone].downcase).id
    self.avatar_url = self.api_result[:xbox_info][:tile_url]
    self.online = self.api_result[:xbox_info][:presence_info][:online] == "false" ? false : true 
    self.location = self.api_result[:xbox_info][:location]
    self.last_online_at = Time.parse(self.api_result[:xbox_info][:presence_info][:last_seen])
    self.gamerscore = self.api_result[:xbox_info][:gamer_score]
    self.reputation = self.api_result[:xbox_info][:reputation]
    self.account_status = self.api_result[:xbox_info][:presence_info][:status_text]
  end
end

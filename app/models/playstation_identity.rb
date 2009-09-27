class PlaystationIdentity < GamerIdentity
  attr_accessor :profile_data, :widget_data, :trophy_data
  has_many :activities, :as => :avatar
  belongs_to :user
  validates_presence_of :user_id, :message => "must be associated with a PSN ID"
  validate_on_create :valid_identity?

  after_validation_on_create :build_attributes

  private
  def invoke_api
    begin
      url = AppConfig.psn_api.url + self.name
      xml_api_result = Net::HTTP.get(URI.parse(url))
      hash_api_result = Hash.from_xml(xml_api_result)
      api_result = HashExtras.underscorize_and_symbolize_all_keys!(hash_api_result)
      logger.info(api_result.inspect) 
    rescue Exception => e
      logger.info("Exception: #{e.message}\n#{e.backtrace.join("\n")}")
      self.errors.add_to_base("An error occurred in the system. Please try again later.")
    end
    return api_result
  end

  def valid_identity?
    return false if self.errors.any?
    self.api_result = invoke_api
    unless self.api_result && self.api_result[:xml][:body][:category].is_a?(Array)
      self.errors.add_to_base("PSN ID was not found. Please ensure that the id is correct")
      return false
    end
    return true
  end

  def build_attributes
    # Even though we create hashes for all the data returned in the API, we only use the profile data to build the identity. The reason
    # why we create other hashes is so that we can add support for trophies and widget displays.
    return false if self.errors.any?
    self.profile_data = HashExtras.underscorize_and_symbolize_all_keys!(self.api_result[:xml][:body][:category].first["item"].first)
    self.widget_data = HashExtras.underscorize_and_symbolize_all_keys!(self.api_result[:xml][:body][:category][1]["item"])
    self.trophy_data = HashExtras.underscorize_and_symbolize_all_keys!(self.api_result[:xml][:body][:category][2]["item"])
    self.category_id = Category.find_or_create_by_name(self.profile_data[:ranking].downcase).id
    self.avatar_url = self.profile_data[:imgurl]
    self.online = self.profile_data[:onlinestate].downcase == "online" ? true : false
  end
end

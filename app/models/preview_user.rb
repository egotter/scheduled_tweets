class PreviewUser
  attr_reader :name, :screen_name, :profile_image_url

  def initialize(user: nil, name: 'NAME', screen_name: 'name', profile_image_url: nil)
    if user
      begin
        twitter_user = user.api_client.user
      rescue => e
        Rails.logger.info e.inspect
        twitter_user = {screen_name: 'name', name: 'NAME', profile_image_url: nil}
      end

      @screen_name = twitter_user[:screen_name]
      @name = twitter_user[:name]
      @profile_image_url = twitter_user[:profile_image_url_https]
    else
      @name = name
      @screen_name = screen_name
      @profile_image_url = profile_image_url
    end
  end
end

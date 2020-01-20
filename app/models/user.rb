class User < ApplicationRecord
  devise :rememberable, :omniauthable

  has_one :credential
  has_many :scheduled_tweets

  attr_accessor :name

  class << self
    def update_or_create_with_token!(values)
      user = find_or_initialize_by(uid: values[:uid])
      user.assign_attributes(screen_name: values[:screen_name], authorized: true, email: values[:email])

      credential = Credential.find_or_initialize_by(user_id: user.id)
      credential.assign_attributes(token: values[:token], secret: values[:secret])

      transaction do
        user.save!
        credential.user_id = user.id
        credential.save!
      end

      user
    end
  end

  def api_client
    ApiClient.new(self)
  end
end

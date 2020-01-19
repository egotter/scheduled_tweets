class User < ApplicationRecord
  devise :omniauthable

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
end

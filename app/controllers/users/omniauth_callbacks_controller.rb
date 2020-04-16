class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def twitter
    user = User.update_or_create_with_token!(user_params)
    sign_in user, event: :authentication
    flash[:notice] = I18n.t('devise.omniauth_callbacks.success', kind: 'twitter')

    thanks = (user.created_at > 10.seconds.ago) ? 'sign_up' : 'sign_in'
    redirect_to root_path(thanks: thanks)
  end

  private

  def user_params
    values = request.env['omniauth.auth'].slice('uid', 'info', 'credentials')

    {
        uid: values['uid'],
        screen_name: values['info']['nickname'],
        secret: values['credentials']['secret'],
        token: values['credentials']['token'],
        email: values['info']['email']
    }
  end
end


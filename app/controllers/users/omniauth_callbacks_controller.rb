class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def twitter
    user = User.update_or_create_with_token!(user_params)
    sign_in user, event: :authentication
    flash[:notice] = I18n.t('devise.omniauth_callbacks.success', kind: 'twitter')
    redirect_to root_path
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


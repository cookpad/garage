require 'exampler'

Garage.configure do
  cast_resource do |res|
    res # FIXME
  end
  docs.exampler do |controller, klass|
    Exampler.new(controller).examples_for(klass)
  end
  docs.current_user_method {
    extend CurrentUserHelper
    current_user
  }
  docs.console_app_uid = ENV['GARAGE_CONSOLE_APP_UID']

  if ENV['GARAGE_REMOTE_SERVER']
    docs.remote_server = ENV['GARAGE_REMOTE_SERVER']
  end
end

Garage::TokenScope.configure do
  register :public do
    access :read, Post
  end

  register :read_private_post do
    access :read, PrivatePost
  end

  register :write_post do
    access :write, Post
  end

  register :read_post_body

  register :sudo, hidden: true
end


Doorkeeper.configure do
  orm :active_record

  resource_owner_authenticator do
    User.find_by_id(session[:user_id]) || redirect_to(new_session_url)
  end
  default_scopes :public
  optional_scopes *Garage::TokenScope.optional_scopes
end

ActiveSupport::Notifications.subscribe "garage.request" do |name, start, finish, id, payload|
  if payload[:application]
    payload[:controller].response.headers['Application-Id'] = payload[:application].uid
  end
end

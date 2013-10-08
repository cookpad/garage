Garage.configure do
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

  register :read_post_body do
    access :read, PostBody
  end

  register :sudo, hidden: true do
    access :read, PrivatePost
    access :read, PostStream
  end

  register :meta do
    access :read, Garage::Meta::RemoteService
  end

  namespace :foobar do
    register :read_post do
      access :read, NamespacedPost
    end
  end
end

Garage::Meta::RemoteService.configure do
  service do
    namespace nil
    name "Main API"
    endpoint "http://api.example.com/v1"
    alternate_endpoint :internal, "http://api-internal.example.amazonaws.com/v1"
  end

  service do
    namespace :foo
    name "Foo API"
    endpoint "http://foo.api.example.com/v1"
    alternate_endpoint :internal, "http://aoo.api-internal.example.amazonaws.com/v1"
  end
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

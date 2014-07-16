require 'oauth2'
require 'http_accept_language'

class Garage::Docs::ResourcesController < Garage::ApplicationController
  layout 'garage/application'

  before_filter :require_authentication
  before_filter :require_docs_application
  before_filter :require_console_application
  before_filter :set_locale
  before_filter :require_document, only: :show

  def index
    @documents = Garage::Docs::Document.all
  end

  def show
    @documents = Garage::Docs::Document.all
    @examples = Garage::Docs::Example.build_all(self, @document.examples(_current_user))
    @title = "#{@document.name.humanize} API"
  end

  def console
    @base_url = "#{request.protocol}#{request.host_with_port}"
  end

  def authenticate
    session[:platform_return_to] = params[:return_to]

    redirect_to oauth2_client(@app).auth_code.authorize_url(
      :redirect_uri => callback_resources_url,
      :scope => params[:scopes].join(' ')
    )
  end

  def callback
    if params[:code]
      client = oauth2_client(@app)

      # This will block if your API server runs on the same process (e.g. Webrick)
      token = client.auth_code.get_token(params[:code], redirect_uri: callback_resources_url)
      session[:access_token] = token.token

      redirect_to session[:platform_return_to] || console_resources_path
    else
      render :layout => false
    end
  end

  def _current_user
    @current_user ||= instance_eval(&Garage.configuration.docs.current_user_method)
  end
  hide_action :_current_user
  helper_method :_current_user

  private

  def console_application
    Doorkeeper::Application.by_uid(Garage.configuration.docs.console_app_uid)
  end

  def remote_server
    value = Garage.configuration.docs.remote_server
    value = value.call(request) if value.is_a? Proc
    value
  end

  def oauth2_client(app)
    OAuth2::Client.new(app.uid, app.secret, :site => remote_server)
  end

  def set_locale
    @locale = params[:lang] || cookies[:garage_locale] || request.preferred_language_from(%w[en ja])
    cookies[:garage_locale] = @locale
  end

  def require_authentication
    instance_eval(&Garage.configuration.docs.authenticate)
  end

  def require_docs_application
    @application = Garage::Docs.application
  end

  def require_console_application
    @app = console_application or render(text: "OAuth app does not exist", status: :forbidden)
  end

  def require_document
    @document = Garage::Docs::Document.find_by_name(params[:id])
    case
    when !@document
      head 404
    when !@document.visible_to?(_current_user)
      head 403
    end
  end
end

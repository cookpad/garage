require 'oauth2'
require 'http_accept_language'

class Garage::Docs::ResourcesController < Garage::ApplicationController
  layout 'garage/application'

  before_filter :require_authentication
  before_filter :require_docs_application
  before_filter :require_console_application
  before_filter :set_locale

  def index
    @documents = Garage::Docs::Document.all
  end

  def show
    @documents = Garage::Docs::Document.all
    @document = Garage::Docs::Document.find_by_name(params[:id])
    @examples = Garage::Docs::Example.where(controller: self, name: params[:id])
  end

  def console
    @base_url = "#{request.protocol}#{request.host_with_port}"
  end

  def authenticate
    session[:platform_return_to] = params[:return_to]

    client = oauth2_client(@app)

    # TODO: because it authenticates against self host provider, use
    # Implicit Grant flow to prevent the callback app accessing itself
    # and blocks with a single process server i.e. Webrick
    redirect_to client.implicit.authorize_url(
      :redirect_uri => garage_docs.callback_resources_url,
      :scope => params[:scopes].join(' ')
    )
  end

  def callback
    if params[:access_token]
      session[:access_token] = params[:access_token]
      redirect_to session[:platform_return_to] || garage_docs.console_resources_path
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
end

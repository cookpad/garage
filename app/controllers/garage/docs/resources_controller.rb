require 'oauth2'

class Garage::Docs::ResourcesController < Garage::ApplicationController
  layout 'garage/application'
  helper_method :_current_user

  @@application = Garage::Docs::Application.new(Rails.application)

  before_filter(&Garage.configuration.docs.authenticate)

  before_filter do
    @application = @@application
  end

  before_filter do
    @app = console_application
    unless @app
      render text: "OAuth app does not exist", status: :forbidden
      return
    end
    if URI.parse(@app.redirect_uri).host != request.host
      render text: "Request URI do not match with OAuth app host: #{@app.redirect_uri}", status: :forbidden
    end
  end

  def index
  end

  def show
    @doc = @@application.doc_for(params[:id].sub(/^Garage::/, ''))
    @examples = Garage.configuration.docs.exampler.call(self, params[:id]).compact.map do |e|
      Garage::Docs::LinkableExample.new(e, self)
    end
  end

  def console
    @base_url = "#{request.protocol}#{request.host_with_port}"
  end

  def authenticate
    session[:platform_return_to] = params[:return_to]

    redirect_to oauth2_client(@app).auth_code.authorize_url(
      :redirect_uri => garage_docs.callback_resources_url,
      :scope => params[:scopes].join(' ')
    )
  end

  def callback
    if params[:code]
      client = oauth2_client(@app)

      token = client.auth_code.get_token(params[:code], redirect_uri: garage_docs.callback_resources_url)
      session[:access_token] = token.token

      redirect_to session[:platform_return_to] || garage_docs.console_resources_path
    else
      render :layout => false
    end
  end

  def _current_user
    instance_eval(&Garage.configuration.docs.current_user_method)
  end

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
end

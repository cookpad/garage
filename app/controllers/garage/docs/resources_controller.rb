require 'oauth2'

class Garage::Docs::ResourcesController < ApplicationController
  force_ssl
  layout 'garage/application'

  @@application = Garage::PantryKit::Application.new(Rails.application)

  before_filter do
    @application = @@application
    # FIXME configure who can access this controller (with/without using CanCan)
    #if current_user
    #  authorize! :use_doc, current_user
    #else
    #  redirect_to(garage_signin_path(to: request.fullpath))
    #end
  end

  before_filter do
    @app = console_application
    if URI.parse(@app.redirect_uri).host != request.host
      render text: "Request URI do not match with OAuth app host: #{@app.redirect_uri}", status: :forbidden
    end
  end

  def index
  end

  def show
    @doc = @@application.doc_for(params[:id].sub(/^Garage::/, ''))
    @routes = @@application.routes_with_docs.select {|route| route.resource == params[:id] }
    @examples = Garage::Docs.config.exampler.call(self, params[:id]).compact.map do |e|
      Garage::LinkableExample.new(e, self)
    end
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

  private

  def console_application
    Doorkeeper::Application.find_or_create_by_name('Pantry Console') do |app|
      app.redirect_uri = garage_docs.callback_resources_url
      app.save! if app.changed?
    end
  end

  def oauth2_client(app)
    OAuth2::Client.new(app.uid, app.secret, :site => "#{request.protocol}#{request.host_with_port}")
  end
end

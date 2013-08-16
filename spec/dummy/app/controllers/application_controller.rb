class ApplicationController < ActionController::Base
  protect_from_forgery

  include CurrentUserHelper
  helper_method :current_user

  rescue_from ActiveRecord::RecordNotFound do
    head 404
  end
end

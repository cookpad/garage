class ApplicationController < ActionController::Base
  protect_from_forgery

  include CurrentUserHelper
  helper_method :current_user
end

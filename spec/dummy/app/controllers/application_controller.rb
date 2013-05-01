class ApplicationController < ActionController::Base
  protect_from_forgery

  include Platform2::ControllerHelper
end

require 'exampler'
include CurrentUserHelper

Garage.configure do
  cast_resource do |res|
    res # FIXME
  end
  docs.exampler do |controller, klass|
    Exampler.new(controller).examples_for(klass)
  end
  docs.current_user_method { current_user }
  docs.console_app_uid = ENV['GARAGE_CONSOLE_APP_UID']

  if ENV['GARAGE_REMOTE_SERVER']
    docs.remote_server = ENV['GARAGE_REMOTE_SERVER']
  end
end

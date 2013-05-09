require 'exampler'

Garage.configure do
  cast_resource do |res|
    res # FIXME
  end
  docs.exampler do |controller, klass|
    Exampler.new(controller).examples_for(klass)
  end
  docs.current_user_method { current_user }
end

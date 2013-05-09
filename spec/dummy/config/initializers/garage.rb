require 'exampler'

Garage.configure do
  cast_resource do |res|
    res # FIXME
  end
  docs.exampler = lambda {|controller, klass| Exampler.new(controller).examples_for(klass) }
  docs.current_user_method = proc { current_user }
end

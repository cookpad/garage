Garage.configure do
  cast_resource do |res|
    res # FIXME
  end
end

require 'exampler'
Garage::Docs.config do |c|
  c.exampler = lambda {|controller, klass| Exampler.new(controller).examples_for(klass) }
end

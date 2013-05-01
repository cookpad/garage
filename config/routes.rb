Platform2::Engine.routes.draw do
  match '*path' => 'resources#handle'
end

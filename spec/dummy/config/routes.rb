Rails.application.routes.draw do
  use_doorkeeper

  resources :posts
  resource :session
end

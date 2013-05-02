Rails.application.routes.draw do
  use_doorkeeper

  mount Platform2::Docs::Engine => '/docs'

  resources :posts
  resource :session
end

Rails.application.routes.draw do
  mount Platform2::Engine => "/platform2"

  resources :posts
end

Rails.application.routes.draw do
  use_doorkeeper

  mount Garage::Docs::Engine => '/docs'

  resources :posts do
    collection do
      get :hide
      get :capped
    end
  end

  resources :users do
    resources :posts
  end

  resource :session
  resource :echo
end

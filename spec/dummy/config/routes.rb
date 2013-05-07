Rails.application.routes.draw do
  use_doorkeeper

  mount Garage::Docs::Engine => '/docs'

  resources :posts do
    collection do
      get :hide
    end
  end

  resources :users do
    resources :posts
  end

  resource :session
  resource :echo do
    get 'whoami'
  end
end

Garage::Docs::Engine.routes.draw do
  root :to => 'resources#index', as: nil
  resources :resources do
    collection do
      get 'console'
      post 'authenticate'
      get 'callback'
      post 'callback'
    end
  end
end

Garage::Meta::Engine.routes.draw do
  resources :services
  resources :docs
end

Garage::Webhook::Engine.routes.draw do
  post '/' => 'events#create'
end

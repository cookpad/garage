Platform2::Engine.routes.draw do
end

Platform2::Docs::Engine.routes.draw do
  root :to => 'resources#index'
  resources :resources do
    collection do
      get 'console'
      post 'authenticate'
      get 'callback'
      post 'callback'
    end
  end
end

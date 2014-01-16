Rails.application.routes.draw do
  use_doorkeeper

  mount Garage::Docs::Engine => '/docs'
  mount Garage::Meta::Engine => '/meta'

  resources :posts do
    collection do
      get :hide
      get :capped
      get :namespaced
    end
  end

  resources :users do
    resources :posts do
      collection do
        get :private
      end
    end
  end

  resource :session
  resource :echo
end

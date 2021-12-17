Rails.application.routes.draw do
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

    resources :public_posts, only: :index
  end

  resources :campaigns
  resource :session
  resource :echo
  resource :ping

  get :mine, to: 'public_posts#my'

  resources :location_test_posts, only: :create
end

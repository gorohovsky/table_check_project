Rails.application.routes.draw do
  resources :products, only: %i[index show], defaults: { format: :json } do
    post 'import', on: :collection
  end

  resources :carts, only: :show, defaults: { format: :json } do
    put 'add_product', on: :collection
  end

  resources :orders, only: %i[index show create], defaults: { format: :json }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end

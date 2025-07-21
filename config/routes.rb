Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post   "/auth/login", to: "auth#login"
      delete "/auth/logout", to: "auth#logout"
      post   "/auth/refresh", to: "auth#refresh"

      resources :users, only: [ :create, :show ]

      resources :statements, only: [ :index, :show ], param: :slug do
        resources :line_items, only: [ :create, :index ],
                               param: :statement_slug,
                               controller: 'statements/line_items'
      end

      resources :line_items, only: [ :index, :show, :update, :destroy ]

    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end

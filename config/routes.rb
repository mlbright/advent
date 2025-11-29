Rails.application.routes.draw do
  # Authentication routes
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  # User routes
  get "change-password", to: "users#edit_password", as: :edit_password
  patch "change-password", to: "users#update_password", as: :update_password

  # Admin routes
  resources :users, only: [ :index, :new, :create, :destroy ]
  resources :request_logs, only: [ :index ]

  # Calendar routes
  resources :calendars do
    member do
      post :shuffle
    end

    resources :calendar_days, param: :day_number, only: [ :show, :edit, :update ] do
      member do
        delete :delete_attachment
        get :swap_initiate
        post :swap_complete
      end
    end
  end

  # Calendar view tracking
  resources :calendar_views, only: [ :create ]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "calendars#index"
end

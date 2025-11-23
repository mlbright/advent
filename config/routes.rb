Rails.application.routes.draw do
  get "calendar_views/create"
  get "content_elements/create"
  get "content_elements/update"
  get "content_elements/destroy"
  get "calendar_days/show"
  get "calendar_days/edit"
  get "calendar_days/update"
  get "calendars/index"
  get "calendars/show"
  get "calendars/new"
  get "calendars/create"
  get "calendars/edit"
  get "calendars/update"
  # Authentication routes
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  # Calendar routes
  resources :calendars do
    resources :calendar_days, param: :day_number, only: [ :show, :edit, :update ]
  end

  # Content element routes
  resources :content_elements, only: [ :create, :update, :destroy ]

  # Calendar view tracking
  resources :calendar_views, only: [ :create ]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "calendars#index"
end

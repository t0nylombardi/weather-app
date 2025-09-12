Rails.application.routes.draw do
  resources :forecast, only: [:index] do
    post :update_forecast, on: :collection
  end
  root "forecast#index"
end

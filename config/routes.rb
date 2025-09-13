Rails.application.routes.draw do
  resources :forecast, only: [:index] do
    post :update_forecast, on: :collection
  end
  root "forecast#index"

  get "/.well-known/appspecific/com.chrome.devtools.json", to: proc { [204, {}, [""]] }
end

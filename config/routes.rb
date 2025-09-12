Rails.application.routes.draw do
  post "/weather" => "forecast#update_forecast", :as => :update_forecast

  root "forecast#index"
end

Rails.application.routes.draw do
  post "/weather" => "forecast#update_forecast", :as => :update_forecast

  root "forecast#index"

  # This was annoying me while developing with Chrome
  # https://stackoverflow.com/questions/51508855/rails-5-chrome-devtools-issue
  get "/.well-known/appspecific/com.chrome.devtools.json", to: proc { [204, {}, [""]] }
end

# frozen_string_literal: true

module Weather
  # Handles communication with the external WeatherAPI service.
  class ApiClient
    # The base URL for the WeatherAPI service.
    API_BASE_URL = "https://api.weatherapi.com/v1/forecast.json"

    # The API key used to authenticate requests. Retrieved from Rails application credentials.
    API_KEY = Rails.application.credentials[:weather_api_key]

    # Performs a GET request for weather forecast.
    #
    # @param location [String] The location to fetch weather for.
    # @return [HTTParty::Response] The raw API response.
    def fetch_forecast(location)
      HTTParty.get(API_BASE_URL, query: params(location))
    end

    private

    def params(location)
      {
        key: API_KEY,
        q: location,
        days: 3,
        aqi: "no",
        alerts: "no"
      }
    end
  end
end

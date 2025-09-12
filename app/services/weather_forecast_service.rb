# frozen_string_literal: true

class WeatherForecastService
  # Custom exception class for handling failures within WeatherForecastService.
  class Failure < StandardError; end

  # The base URL for the WeatherAPI service.
  API_BASE_URL = "https://api.weatherapi.com/v1/forecast.json"

  # The API key used to authenticate requests. Retrieved from Rails application credentials.
  API_KEY = Rails.application.credentials[:weather_api_key]

  # Initializes a new WeatherForecastService instance.
  #
  # @param location [String] The location for which the weather forecast is requested.
  # @param postal_code [String, nil] The postal code of the location (optional, used for caching purposes).
  def initialize(location:, postal_code: nil)
    @location = location
    @postal_code = postal_code
  end

  # Retrieves the weather forecast for the specified location.
  #
  # @return [Hash, nil] Weather forecast data if successful, otherwise nil.
  #
  # @note Checks the cache for previously fetched data. If available, returns the cached data.
  #   Otherwise, fetches data from the API and caches it.
  def forecast
    return unless @location

    cached_data = Rails.cache.read(cache_key)
    return cached_data if cached_data

    fetch_data_from_api
  end

  private

  # Fetches forecast data from the WeatherAPI.
  #
  # @return [Hash] Forecast data if successful.
  # @raise [Failure] If the API request fails.
  def fetch_data_from_api
    response = api_request

    response.success? ? successful_response(response) : failed_response(response)
  end

  # Defines parameters for the WeatherAPI request.
  #
  # @return [Hash] API request parameters.
  def params
    {
      key: API_KEY,
      q: @location,
      days: 5,
      aqi: "no",
      alerts: "no",
      hour: 24
    }
  end

  # Makes a GET request to the WeatherAPI.
  #
  # @return [HTTParty::Response] HTTParty response object.
  def api_request
    HTTParty.get(API_BASE_URL, query: params)
  end

  # Handles a successful API response by parsing the body.
  #
  # @param response [HTTParty::Response] Successful response object.
  # @return [Hash] Parsed forecast data.
  def successful_response(response)
    parse_response(response.body)
  end

  # Handles a failed API response by calling the handle_error method.
  #
  # @param response [HTTParty::Response] Failed response object.
  # @return [String] Result of the handle_error method.
  def failed_response(response)
    handle_error(response)
  end

  # Parses the JSON response body and extracts forecast data.
  #
  # @param response_body [String] JSON response body.
  # @return [Hash] Forecast data.
  def parse_response(response_body)
    data = JSON.parse(response_body)
    Rails.logger.info("WeatherAPI response: #{data}")

    cache_forecast(data) unless @postal_code.nil?
    data
  end

  # Caches forecast data using Rails caching.
  #
  # @param data [Hash] Forecast data to be cached.
  def cache_forecast(data)
    Rails.cache.write(cache_key,
      data.merge(cached: true),
      expires_at: 30.minutes.from_now)
  end

  # Generates a cache key based on the postal code.
  #
  # @return [String] Cache key string.
  def cache_key
    "weather_forecast_#{@postal_code}"
  end

  # Handles errors by returning the response body.
  #
  # @param response [HTTParty::Response] Failed response object.
  # @return [Json] Response body as a json object.
  def handle_error(response)
    JSON.parse(response.body)
  end
end

# frozen_string_literal: true

# The ForecastController handles requests related to weather forecasts.
# It interacts with the WeatherForecastService to fetch and display forecast data.
class ForecastController < ApplicationController
  # Renders the index view for weather forecasting.
  def index
  end

  # Updates the weather forecast for a given location and renders the weather dashboard component.
  def update_forecast
    forecast = fetch_weather_data(location)
    handle_failed_fetch(forecast) unless forecast["error"].nil?

    puts "\n\nForecast data: #{forecast.inspect}\n\n"
    respond_to do |format|
      # format.html { render_component(forecast) }
      format.turbo_stream do
        render turbo_stream:
          turbo_stream.update("forecast",
            partial: "weather_dashboard",
            locals: {forecast:})
      end
    end
  end

  private

  # Renders the weather dashboard component using Turbo Streams.
  #
  # @param forecast [Hash] The weather forecast data to be rendered.
  def render_component(forecast)
    puts "\n\nRendering component with forecast: #{forecast.inspect}\n\n"
    render turbo_stream:
      turbo_stream.update("forecast",
        partial: "weather_dashboard",
        locals: {forecast:})
  end

  # Retrieves the location parameter from the request.
  #
  # @return [String] The location for which the weather forecast is requested.
  def location
    params[:location]
  end

  # Retrieves the postal code parameter from the request.
  #
  # @return [String] The postal code of the location.
  def postal_code
    params[:postal_code]
  end

  # Fetches weather forecast data from the WeatherForecastService.
  #
  # @param location [String] The location for which the forecast data is requested.
  # @return [Hash, nil] The weather forecast data if successful, otherwise nil.
  def fetch_weather_data(location)
    WeatherForecastService.new(location:, postal_code:).forecast
  end

  # Handles the case where the forecast data fetch fails, displaying an alert message.
  #
  # @param forecast [Hash] The weather forecast data containing an error message.
  def handle_failed_fetch(forecast)
    flash.now[:alert] = forecast["error"]["message"]
  end
end

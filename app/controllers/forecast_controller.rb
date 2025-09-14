# frozen_string_literal: true

# The ForecastController handles requests related to weather forecasts.
# It uses the WeatherForecastService to retrieve and render forecast data.
class ForecastController < ApplicationController
  # GET /forecast
  # Renders the index view for entering forecast search criteria.
  def index
  end

  # POST /forecast/update
  # Retrieves the forecast for the given parameters and renders the weather dashboard.
  def update_forecast
    forecast = fetch_weather_data
    handle_failed_fetch(forecast) if forecast["error"].present?

    respond_to do |format|
      format.turbo_stream { render_component(forecast) }
      # format.html { redirect_to root_path }
    end
  end

  private

  # Strong parameters for forecast requests.
  #
  # @return [ActionController::Parameters] Sanitized parameters with location and postal_code
  def forecast_params
    params.except(:authenticity_token).permit(:location, :postal_code)
  end

  # Fetches weather forecast data using the Weather::ForecastService.
  #
  # @return [Hash] Weather forecast data, including error details if the fetch fails
  def fetch_weather_data
    Weather::ForecastService.call(
      location: forecast_params[:location],
      postal_code: forecast_params[:postal_code]
    )
  end

  # Renders the weather dashboard and form Turbo Stream components.
  #
  # @param forecast [Hash] The weather forecast data to render
  def render_component(forecast)
    render turbo_stream: [
      turbo_stream.replace(
        "forecast",
        partial: "forecast",
        locals: {forecast: forecast}
      ),
      turbo_stream.update(
        "location_form",
        partial: "location_form"
      )
    ]
  end

  # Handles the case where the forecast fetch fails by displaying an alert message.
  #
  # @param forecast [Hash] Forecast data including error information
  def handle_failed_fetch(forecast)
    flash.now[:alert] = forecast["error"]["message"]
  end
end

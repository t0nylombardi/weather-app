# frozen_string_literal: true

module ForecastHelper
  # Displays a "Cached" metadata panel if the forecast data includes cache info.
  #
  # @param forecast [Hash, String] The weather forecast data or an error string.
  # @return [String, nil] HTML-safe string indicating cached status, or nil.
  def display_cached_text(forecast:)
    return "Forecast not found" if forecast.is_a?(String)

    cached = forecast[:cached]
    return unless cached.present?

    content_tag :div, class: "absolute top-4 left-4 z-5" do
      cached_metadata(forecast, cached)
    end
  end

  private

  # Renders cached metadata (timestamp, address, etc.)
  #
  # @param forecast [Hash] The weather forecast data.
  # @param cached [Hash] Cached metadata hash containing :at, :location, :postal_code.
  # @return [String] HTML-safe content.
  def cached_metadata(forecast, cached)
    location = forecast.fetch("location", {})

    content_tag(:p, class: "flex flex-col gap-1 text-md text-love") do
      safe_join(
        [
          content_tag(:span, "Cached at: #{format_timestamp(cached["at"])}"),
          content_tag(:span, "Address: #{format_address(location)}"),
          content_tag(:span, "Postcode: #{cached["postal_code"]}"),
          content_tag(:span, "Timezone: #{location["tz_id"]}")
        ].compact
      )
    end
  end

  # Formats a location hash into a readable address.
  #
  # @param location [Hash] Location hash from forecast data.
  # @return [String] Formatted address string.
  def format_address(location)
    [location["name"], location["region"], location["country"]].compact.join(", ")
  end

  # Formats a timestamp string into a more human-readable format.
  #
  # @param timestamp [String, Time] Raw timestamp from the cache metadata.
  # @return [String] Human-friendly formatted timestamp.
  def format_timestamp(timestamp)
    Time.parse(timestamp.to_s).strftime("%b %d, %Y %l:%M %p")
  rescue ArgumentError, TypeError
    timestamp.to_s
  end

  # Displays flash alerts in a consistent style.
  #
  # @return [String, nil] HTML-safe flash alert or nil if none exists.
  def display_flash_alerts
    return unless flash[:alert]

    content_tag(:div, flash[:alert], class: "text-md text-love font-medium")
  end
end

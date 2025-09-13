module ForecastHelper
  # Displays a "Cached" text indicator if the forecast data is cached.
  #
  # @param [Hash] forecast The weather forecast data.
  # @return [String, nil] The HTML safe string indicating cached status, or nil.
  def display_cached_text(forecast)
    return if forecast.instance_of?(String)

    content_tag :div, class: "absolute top-4 left-4" do
      cached_text(forecast)
    end
  end

  def cached_text(forecast)
    '<p class="text-lg">Cached</p>'.html_safe if forecast&.dig(:cached)
  end

  def display_flash_alerts
    return if flash[:alert].nil?

    content_tag(:div, class: "text-md text-rose") do
      flash[:alert]
    end
  end
end

module ForecastHelper
  # Displays a "Cached" text indicator if the forecast data is cached.
  #
  # @param [Hash] forecast The weather forecast data.
  # @return [String, nil] The HTML safe string indicating cached status, or nil.
  def display_cached_text(forecast)
    return if forecast.instance_of?(String)

    '<p class="text-sm">Cached</p>'.html_safe if forecast[:cached]
  end

  def display_flash_alerts
    return if flash[:alert].nil?

    content_tag(:div, class: "text-md text-rose") do
      flash[:alert]
    end
  end
end

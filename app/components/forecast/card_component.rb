# frozen_string_literal: true

module Forecast
  # A component that displays a weather forecast card.
  #
  class CardComponent < ViewComponent::Base
    # Initializes a new CardComponent.
    #
    # @param [Date, String] date The date of the forecast.
    # @param [Integer] current The current temperature.
    # @param [Integer] high The high temperature for the day.
    # @param [Integer] low The low temperature for the day.
    # @param [String] description A brief description of the weather.
    # @param [String] image The URL of the weather condition icon.
    # @param [String] timezone The tz_id string from forecast['location'] (e.g., "America/New_York").
    def initialize(date:, current:, high:, low:, description:, image:, timezone:)
      @date = date.to_date
      @current = current
      @high = high
      @low = low
      @description = description
      @image = image
      @timezone = timezone
    end

    # Whether this card represents "today" in the forecast location's timezone.
    #
    # @return [Boolean]
    def show_current?
      Time.find_zone(timezone).today == date
    end

    private

    attr_reader :date, :current, :high, :low, :description, :image, :timezone
  end
end

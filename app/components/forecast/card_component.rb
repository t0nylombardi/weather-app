# frozen_string_literal: true

module Forecast
  # A component that displays a weather forecast card.
  #
  class CardComponent < ViewComponent::Base
    # Initializes a new CardComponent.
    #
    # @param [Date] date The date of the forecast.
    # @param [Integer] current The current temperature.
    # @param [Integer] high The high temperature for the day.
    # @param [Integer] low The low temperature for the day.
    # @param [String] description A brief description of the weather.
    # @param [String] image The URL of the weather condition icon.
    # @param [Boolean] show_current Whether to show the current temperature.
    def initialize(date:, current:, high:, low:, description:, image:, show_current: false)
      @date = date.to_date
      @current = current
      @high = high
      @low = low
      @description = description
      @image = image
      @show_current = show_current
    end

    private

    attr_reader :date, :current, :high, :low, :description, :image, :show_current
  end
end

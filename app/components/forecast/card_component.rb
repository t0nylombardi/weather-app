# frozen_string_literal: true

module Forecast
  class CardComponent < ViewComponent::Base
    def initialize(date:, current:, high:, low:, description:, image:)
      @date = date.to_date
      @current = current
      @high = high
      @low = low
      @description = description
      @image = image
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe Forecast::CardComponent, type: :component do
  it "renders forecast details with current when show_current" do
    date = Date.today
    result = render_inline(
      described_class.new(
        date: date,
        current: 70,
        high: 75,
        low: 60,
        description: "Sunny",
        image: "/icons/sun.png",
        show_current: true
      )
    )

    expect(result.text).to include(date.strftime("%B"))
    expect(result.text).to include("Current: 70°")
    expect(result.text).to include("75°")
    expect(result.text).to include("60°")
    expect(result.text).to include("Sunny")
    img = result.at_css("img")
    expect(img[:src]).to eq("/icons/sun.png")
    expect(img[:alt]).to eq("Sunny")
  end

  it "omits current when show_current is false" do
    result = render_inline(
      described_class.new(
        date: Date.today,
        current: 70,
        high: 75,
        low: 60,
        description: "Cloudy",
        image: "/icons/cloud.png",
        show_current: false
      )
    )

    expect(result.text).not_to include("Current:")
  end
end

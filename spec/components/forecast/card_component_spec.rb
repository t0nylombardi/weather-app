# frozen_string_literal: true

require "rails_helper"

RSpec.describe Forecast::CardComponent, type: :component do
  let(:timezone) { "UTC" }

  context "when date is today in timezone" do
    subject(:component) do
      described_class.new(
        date: Time.find_zone(timezone).today,
        current: 70,
        high: 75,
        low: 60,
        description: "Sunny",
        image: "/icons/sun.png",
        timezone: timezone
      )
    end

    let(:result) { render_inline(component) }

    it "renders the month name" do
      expect(result.text).to include(component.send(:date).strftime("%B"))
    end

    it "renders current temperature" do
      expect(result.text).to include("Current: 70°")
    end

    it "renders high and low temperatures" do
      expect(result.text).to include("75°")
      expect(result.text).to include("60°")
    end

    it "renders description" do
      expect(result.text).to include("Sunny")
    end

    it "renders image with correct src and alt" do
      img = result.at_css("img")
      expect(img[:src]).to eq("/icons/sun.png")
      expect(img[:alt]).to eq("Sunny")
    end
  end

  context "when date is not today in timezone" do
    subject(:component) do
      described_class.new(
        date: Time.find_zone(timezone).tomorrow,
        current: 70,
        high: 75,
        low: 60,
        description: "Cloudy",
        image: "/icons/cloud.png",
        timezone: timezone
      )
    end

    let(:result) { render_inline(component) }

    it "omits current temperature" do
      expect(result.text).not_to include("Current:")
    end
  end
end

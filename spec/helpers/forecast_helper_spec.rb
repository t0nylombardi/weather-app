# frozen_string_literal: true

require "rails_helper"

RSpec.describe ForecastHelper, type: :helper do
  describe "#display_cached_text" do
    it "returns plain message when forecast is a String" do
      result = helper.display_cached_text(forecast: "Not found")
      expect(result).to eq("Forecast not found")
    end

    it "returns nil when no cached metadata present" do
      result = helper.display_cached_text(forecast: {"location" => {}})
      expect(result).to be_nil
    end

    it "renders cached metadata when present" do
      forecast = {
        "location" => {"name" => "New York", "region" => "NY", "country" => "USA"},
        :cached => {at: "2024-01-02 15:30:00 -0500", location: "New York", postal_code: "10001"}
      }

      html = helper.display_cached_text(forecast: forecast)
      doc = Nokogiri::HTML.fragment(html)

      wrapper = doc.at_css("div.absolute.top-4.left-4.z-5")
      expect(wrapper).to be_present

      text = wrapper.text
      expect(text).to match(/Cached at: Jan 02, 2024\s+3:30 PM/)
      expect(text).to include("Address: New York, NY, USA")
      expect(text).to include("Postal Code: 10001")
    end
  end

  describe "#format_address" do
    it "joins name, region, and country" do
      address = helper.send(:format_address, {"name" => "Boston", "region" => "MA", "country" => "USA"})
      expect(address).to eq("Boston, MA, USA")
    end

    it "skips missing parts" do
      address = helper.send(:format_address, {"name" => "Paris", "country" => "France"})
      expect(address).to eq("Paris, France")
    end
  end

  describe "#format_timestamp" do
    it "formats a valid timestamp" do
      formatted = helper.send(:format_timestamp, "2024-01-02 15:30:00 -0500")
      expect(formatted).to match(/Jan 02, 2024\s+3:30 PM/)
    end

    it "returns input as string on error" do
      formatted = helper.send(:format_timestamp, :invalid)
      expect(formatted).to eq("invalid")
    end
  end

  describe "#display_flash_alerts" do
    it "returns nil when no alert" do
      flash.clear
      expect(helper.send(:display_flash_alerts)).to be_nil
    end

    it "renders alert when present" do
      flash[:alert] = "Something went wrong"
      html = helper.send(:display_flash_alerts)
      doc = Nokogiri::HTML.fragment(html)
      node = doc.at_css("div.text-md.text-love.font-medium")
      expect(node).to be_present
      expect(node.text).to eq("Something went wrong")
    end
  end
end

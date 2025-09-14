# frozen_string_literal: true

require "rails_helper"

RSpec.describe Weather::CacheRepository do
  describe "#read" do
    context "when nothing is cached" do
      it "returns nil" do
        repo = described_class.new(location: "New York")
        expect(Rails.cache).to receive(:read).with("weather_forecast_new-york").and_return(nil)
        expect(repo.read).to be_nil
      end
    end

    context "when cached data is a Hash" do
      it "returns the hash as-is" do
        repo = described_class.new(location: "New York")
        data = {"temp" => 70}
        expect(Rails.cache).to receive(:read).with("weather_forecast_new-york").and_return(data)
        expect(repo.read).to eq(data)
      end
    end

    context "when cached data is a JSON String" do
      it "parses and returns the hash" do
        repo = described_class.new(location: "New York")
        data = {"temp" => 70}
        expect(Rails.cache).to receive(:read).with("weather_forecast_new-york").and_return(data.to_json)
        expect(repo.read).to eq(data)
      end
    end
  end

  describe "#write" do
    let(:frozen_time) { Time.new(2024, 1, 2, 15, 30, 0, "-05:00") } # EST

    before do
      allow(Time).to receive(:current).and_return(frozen_time)
    end

    it "writes with metadata and expiration when using location key" do
      repo = described_class.new(location: "San Francisco, CA")
      payload = {"temp" => 65}

      expected_key = "weather_forecast_san-francisco-ca"
      expected_data = payload.merge({
        cached: {
          at: "Jan 02, 2024 03:30 PM",
          location: "San Francisco, CA",
          postal_code: nil
        }
      })

      expect(Rails.cache).to receive(:write).with(expected_key, expected_data, expires_in: 30.minutes)
      repo.write(payload)
    end

    it "writes using postal_code key when provided" do
      repo = described_class.new(postal_code: "10001", location: "New York")
      payload = {"temp" => 70}

      expected_key = "weather_forecast_10001"
      expected_data = payload.merge({
        cached: {
          at: "Jan 02, 2024 03:30 PM",
          location: "New York",
          postal_code: "10001"
        }
      })

      expect(Rails.cache).to receive(:write).with(expected_key, expected_data, expires_in: 30.minutes)
      repo.write(payload)
    end
  end
end

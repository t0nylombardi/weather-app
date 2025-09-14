require "rails_helper"

RSpec.describe Weather::ForecastService do
  subject(:call_service) { described_class.new(location: location, postal_code: postal_code).call }

  let(:location) { "New York" }
  let(:postal_code) { nil }

  let(:api_client) { instance_double(Weather::ApiClient) }
  let(:cache_repo) { instance_double(Weather::CacheRepository) }

  before do
    allow(Weather::ApiClient).to receive(:new).and_return(api_client)
    allow(Weather::CacheRepository).to receive(:new)
      .with(postal_code: postal_code, location: location)
      .and_return(cache_repo)
  end

  describe ".call" do
    it "delegates to an instance" do
      expect(described_class).to receive(:new).with(location: location, postal_code: postal_code).and_call_original
      allow(cache_repo).to receive(:read).and_return({})

      expect { call_service }.not_to raise_error
    end
  end

  describe "#call" do
    context "when location is nil" do
      let(:location) { nil }

      it "returns an empty hash" do
        expect(call_service).to eq({})
      end

      it "does not perform an API request" do
        expect(api_client).not_to receive(:fetch_forecast)
        call_service
      end
    end

    context "when cached data exists" do
      let(:cached_data) { {"temp" => 70, "cached" => {"at" => "now"}} }

      before do
        allow(cache_repo).to receive(:read).and_return(cached_data)
      end

      it "returns cached data" do
        expect(call_service).to eq(cached_data)
      end

      it "does not call the API" do
        expect(api_client).not_to receive(:fetch_forecast)
        call_service
      end
    end

    context "when cache is empty and API succeeds" do
      let(:api_response) { instance_double(HTTParty::Response, success?: true, body: {temp: 72}.to_json) }

      before do
        allow(cache_repo).to receive(:read).and_return(nil)
        allow(api_client).to receive(:fetch_forecast).with(location).and_return(api_response)
        allow(cache_repo).to receive(:write)
      end

      it "parses, caches, and returns API data" do
        expect(cache_repo).to receive(:write).with({"temp" => 72})
        expect(call_service).to eq({"temp" => 72})
      end
    end

    context "when cache is empty and API fails with JSON error" do
      let(:error_body) { {error: {message: "Bad request"}}.to_json }
      let(:api_response) { instance_double(HTTParty::Response, success?: false, body: error_body) }

      before do
        allow(cache_repo).to receive(:read).and_return(nil)
        allow(api_client).to receive(:fetch_forecast).with(location).and_return(api_response)
      end

      it "raises a Failure with the API error message" do
        expect { call_service }.to raise_error(Weather::ForecastService::Failure, "Bad request")
      end

      it "does not cache anything" do
        expect(cache_repo).not_to receive(:write)
        begin
          call_service
        rescue Weather::ForecastService::Failure
        end
      end
    end

    context "when cache is empty and API fails with non-JSON body" do
      let(:api_response) { instance_double(HTTParty::Response, success?: false, body: "Service down") }

      before do
        allow(cache_repo).to receive(:read).and_return(nil)
        allow(api_client).to receive(:fetch_forecast).with(location).and_return(api_response)
      end

      it "raises a Failure with the default message" do
        expect { call_service }.to raise_error(Weather::ForecastService::Failure, "Weather API request failed")
      end
    end
  end
end

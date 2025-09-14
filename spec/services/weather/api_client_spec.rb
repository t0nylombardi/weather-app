require "rails_helper"

RSpec.describe Weather::ApiClient do
  subject(:client) { described_class.new }

  describe "#fetch_forecast" do
    let(:location) { "New York" }
    let(:response) { instance_double(HTTParty::Response) }

    before do
      # Ensure a stable API key for the test
      stub_const("Weather::ApiClient::API_KEY", "TEST_KEY")
    end

    it "performs a GET request with the expected params" do
      expected_query = {
        key: "TEST_KEY",
        q: location,
        days: 3,
        aqi: "no",
        alerts: "no"
      }

      expect(HTTParty)
        .to receive(:get)
        .with(Weather::ApiClient::API_BASE_URL, query: expected_query)
        .and_return(response)

      expect(client.fetch_forecast(location)).to be(response)
    end
  end
end


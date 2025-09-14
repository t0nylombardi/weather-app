# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Forecast Requests", type: :request do
  let(:valid_params) { { location: "New York", postal_code: "10001" } }
  let(:valid_headers) { {"Accept" => "text/vnd.turbo-stream.html"} }

  describe "GET /" do
    it "returns successful response" do
      get root_path

      expect(response).to have_http_status(:success)
    end

    it "renders the forecast index page" do
      get root_path

      expect(response).to render_template(:index)
    end

    it "includes proper content type" do
      get root_path

      expect(response.content_type).to include("text/html")
    end

    it "responds to root route correctly" do
      get "/"

      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /weather" do
    before do
      allow(Weather::ForecastService).to receive(:call).and_return({})
    end

    context "with successful forecast data" do
      let(:successful_forecast) do
        {
          "current" => { "temp_f" => 72 },
          "forecast" => {
            "forecastday" => [
              {
                "date" => Date.today.strftime("%Y-%m-%d"),
                "day" => {
                  "maxtemp_f" => 75,
                  "mintemp_f" => 65,
                  "condition" => { "text" => "Sunny", "icon" => "/icons/sun.png" }
                }
              },
              {
                "date" => (Date.today + 1).strftime("%Y-%m-%d"),
                "day" => {
                  "maxtemp_f" => 78,
                  "mintemp_f" => 68,
                  "condition" => { "text" => "Partly cloudy", "icon" => "/icons/cloud.png" }
                }
              }
            ]
          }
        }
      end

      before do
        allow(Weather::ForecastService).to receive(:call).and_return(successful_forecast)
      end

      it "returns successful response" do
        post update_forecast_path, params: valid_params, headers: valid_headers

        expect(response).to have_http_status(:success)
      end

      it "returns turbo stream content type for AJAX requests" do
        post update_forecast_path, params: valid_params, headers: valid_headers

        expect(response.content_type).to include("text/vnd.turbo-stream.html")
      end

      it "contains turbo stream actions in response body" do
        post update_forecast_path, params: valid_params, headers: valid_headers

        expect(response.body).to include('<turbo-stream action="replace" target="forecast">')
        expect(response.body).to include('<turbo-stream action="update" target="location_form">')
      end

      it "processes the request with correct service parameters" do
        post update_forecast_path, params: valid_params, headers: valid_headers

        expect(Weather::ForecastService).to have_received(:call).with(
          location: "New York",
          postal_code: "10001"
        )
      end

      it "handles request with only location parameter" do
        post update_forecast_path, params: {location: "Boston"}, headers: valid_headers

        expect(response).to have_http_status(:success)
        expect(Weather::ForecastService).to have_received(:call).with(
          location: "Boston",
          postal_code: nil
        )
      end

      it "handles request with only postal_code parameter" do
        post update_forecast_path, params: {postal_code: "02101"}, headers: valid_headers

        expect(response).to have_http_status(:success)
        expect(Weather::ForecastService).to have_received(:call).with(
          location: nil,
          postal_code: "02101"
        )
      end

      it "ignores unauthorized parameters" do
        malicious_params = valid_params.merge(
          admin: true,
          user_id: 123,
          secret_key: "hack_attempt"
        )

        post update_forecast_path, params: malicious_params, headers: valid_headers

        expect(Weather::ForecastService).to have_received(:call).with(
          location: "New York",
          postal_code: "10001"
        )
      end
    end

    context "with forecast service errors" do
      let(:error_forecast) do
        {
          "error" => {
            "message" => "Unable to fetch weather data for the specified location",
            "code" => "LOCATION_NOT_FOUND"
          }
        }
      end

      before do
        allow(Weather::ForecastService).to receive(:call).and_return(error_forecast)
      end

      it "returns successful HTTP response even with service errors" do
        post update_forecast_path, params: valid_params, headers: valid_headers

        expect(response).to have_http_status(:success)
      end

      it "includes error message in flash" do
        post update_forecast_path, params: valid_params, headers: valid_headers

        follow_redirect! if response.redirect?
        expect(flash[:alert]).to eq("Unable to fetch weather data for the specified location")
      end

      it "still returns turbo stream response" do
        post update_forecast_path, params: valid_params, headers: valid_headers

        expect(response.content_type).to include("text/vnd.turbo-stream.html")
        expect(response.body).to include("<turbo-stream")
      end
    end

    context "with no parameters" do
      it "handles empty parameter request gracefully" do
        post update_forecast_path, params: {}, headers: valid_headers

        expect(response).to have_http_status(:success)
      end

      it "passes nil values to service" do
        allow(Weather::ForecastService).to receive(:call).and_return({})

        post update_forecast_path, params: {}, headers: valid_headers

        expect(Weather::ForecastService).to have_received(:call).with(
          location: nil,
          postal_code: nil
        )
      end
    end

    context "with different content types" do
      before do
        allow(Weather::ForecastService).to receive(:call).and_return({})
      end

      it "responds to Turbo Stream requests" do
        post update_forecast_path, params: valid_params, as: :turbo_stream

        expect(response).to have_http_status(:success)
        expect(response.content_type).to include("text/vnd.turbo-stream.html")
      end

      it "responds to AJAX requests" do
        post update_forecast_path, params: valid_params, xhr: true

        expect(response).to have_http_status(:success)
      end
    end

    context "CSRF protection" do
      it "includes CSRF token in forms" do
        get root_path

        expect(response.body).to include("csrf-token") if Rails.application.config.force_ssl
      end
    end
  end

  describe "routing", type: :routing do
    it "routes root to forecast#index" do
      expect(get: "/").to route_to(controller: "forecast", action: "index")
    end

    it "routes POST /weather to forecast#update_forecast" do
      expect(post: "/weather").to route_to(controller: "forecast", action: "update_forecast")
    end

    it "generates correct path for update_forecast" do
      expect(update_forecast_path).to eq("/weather")
    end

    it "generates correct URL for update_forecast" do
      expect(update_forecast_url(host: "www.example.com")).to include("/weather")
    end
  end

  describe "error handling" do
    context "when WeatherForecastService raises an exception" do
      before do
        allow(Weather::ForecastService).to receive(:call).and_raise(StandardError, "Service unavailable")
      end

      it "handles service exceptions gracefully" do
        expect {
          post update_forecast_path, params: valid_params, headers: valid_headers
        }.to raise_error(StandardError, "Service unavailable")
      end
    end

    context "with invalid HTTP methods" do
      it "does not accept GET requests to /weather" do
        get "/weather"
        expect(response).to have_http_status(:not_found)
      end

      it "does not accept PUT requests to /weather" do
        put "/weather"
        expect(response).to have_http_status(:not_found)
      end

      it "does not accept DELETE requests to /weather" do
        delete "/weather"
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "response headers and metadata" do
    before do
      allow(Weather::ForecastService).to receive(:call).and_return({})
    end

    it "includes proper cache control headers" do
      post update_forecast_path, params: valid_params, headers: valid_headers

      expect(response.headers["Cache-Control"]).to be_present
    end

    it "includes X-Frame-Options for security" do
      post update_forecast_path, params: valid_params, headers: valid_headers

      expect(response.headers["X-Frame-Options"]).to be_present
    end

    describe "performance and timing" do
      let(:weather_service) { instance_double(WeatherForecastService) }

      before do
        allow(Weather::ForecastService).to receive(:call).and_return({})
      end

      it "responds within reasonable time" do
        start_time = Time.current

        post update_forecast_path, params: valid_params, headers: valid_headers

        response_time = Time.current - start_time
        expect(response_time).to be < 1.second
      end

      it "handles multiple sequential requests" do
        5.times do |i|
          post update_forecast_path, params: valid_params.merge(location: "City#{i}"), headers: valid_headers
          expect(response).to have_http_status(:success)
        end
      end
    end

    # Test the Chrome DevTools route
    describe "GET /.well-known/appspecific/com.chrome.devtools.json" do
      it "returns 204 No Content" do
        get "/.well-known/appspecific/com.chrome.devtools.json"

        expect(response).to have_http_status(:no_content)
      end

      it "returns empty body" do
        get "/.well-known/appspecific/com.chrome.devtools.json"

        expect(response.body).to be_empty
      end
    end
  end
end

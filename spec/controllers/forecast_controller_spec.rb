# frozen_string_literal: true

require "rails_helper"

RSpec.describe ForecastController, type: :controller do
  describe "GET #index" do
    it "renders the index template" do
      get :index
      expect(response).to render_template(:index)
    end

    it "returns a successful response" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #update_forecast" do
    let(:location) { "New York" }
    let(:postal_code) { "10001" }
    let(:forecast_params) { {location: location, postal_code: postal_code} }
    before do
      allow(Weather::ForecastService).to receive(:call).and_return({})
    end

    context "when forecast data is successfully retrieved" do
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
              }
            ]
          }
        }
      end

      before do
        allow(Weather::ForecastService).to receive(:call).and_return(successful_forecast)
      end

      it "calls ForecastService with correct parameters" do
        post :update_forecast, params: forecast_params, format: :turbo_stream

        expect(Weather::ForecastService).to have_received(:call).with(
          location: location,
          postal_code: postal_code
        )
      end

      it "responds with turbo_stream format" do
        post :update_forecast, params: forecast_params, format: :turbo_stream

        expect(response.content_type).to include("text/vnd.turbo-stream.html")
      end

      it "renders the forecast and location_form partials" do
        post :update_forecast, params: forecast_params, format: :turbo_stream

        expect(response.body).to include('turbo-stream action="replace" target="forecast"')
        expect(response.body).to include('turbo-stream action="update" target="location_form"')
      end

      # Rendering locals are exercised by the view; response contains turbo streams

      it "returns a successful response" do
        post :update_forecast, params: forecast_params, format: :turbo_stream

        expect(response).to have_http_status(:success)
      end
    end

    context "when forecast fetch fails" do
      let(:failed_forecast) do
        {
          "error" => {
            "message" => "Unable to fetch weather data for the specified location"
          }
        }
      end

      before do
        allow(Weather::ForecastService).to receive(:call).and_return(failed_forecast)
      end

      it "sets flash alert with error message" do
        post :update_forecast, params: forecast_params, format: :turbo_stream

        expect(flash[:alert]).to eq("Unable to fetch weather data for the specified location")
      end

      it "still renders the turbo_stream response" do
        post :update_forecast, params: forecast_params, format: :turbo_stream

        expect(response.content_type).to include("text/vnd.turbo-stream.html")
        expect(response).to have_http_status(:success)
      end
    end

    context "parameter handling" do
      it "filters out authenticity_token from parameters" do
        params_with_token = {
          location: location,
          postal_code: postal_code,
          authenticity_token: "fake_token"
        }

        post :update_forecast, params: params_with_token, format: :turbo_stream

        expect(Weather::ForecastService).to have_received(:call).with(
          location: location,
          postal_code: postal_code
        )
      end

      it "permits only location and postal_code parameters" do
        params_with_extra = {
          location: location,
          postal_code: postal_code,
          malicious_param: "hacker_data",
          another_param: "should_be_filtered"
        }

        allow(Weather::ForecastService).to receive(:call).and_return({})
        post :update_forecast, params: params_with_extra, format: :turbo_stream

        expect(Weather::ForecastService).to have_received(:call).with(
          location: location,
          postal_code: postal_code
        )
      end

      it "handles missing parameters gracefully" do
        allow(Weather::ForecastService).to receive(:call).and_return({})
        post :update_forecast, params: {}, format: :turbo_stream

        expect(Weather::ForecastService).to have_received(:call).with(
          location: nil,
          postal_code: nil
        )
      end
    end

    context "error handling edge cases" do
      it "handles forecast with empty error hash" do
        forecast_with_empty_error = {"error" => {}}
        allow(Weather::ForecastService).to receive(:call).and_return(forecast_with_empty_error)

        expect {
          post :update_forecast, params: forecast_params, format: :turbo_stream
        }.not_to raise_error
      end

      it "handles forecast with nil error" do
        forecast_with_nil_error = {"error" => nil}
        allow(Weather::ForecastService).to receive(:call).and_return(forecast_with_nil_error)

        expect {
          post :update_forecast, params: forecast_params, format: :turbo_stream
        }.not_to raise_error
      end

      it "handles completely empty forecast response" do
        empty_forecast = {}
        allow(Weather::ForecastService).to receive(:call).and_return(empty_forecast)

        expect {
          post :update_forecast, params: forecast_params, format: :turbo_stream
        }.not_to raise_error
      end
    end
  end

  describe "private methods" do
    let(:controller_instance) { described_class.new }

    describe "#forecast_params" do
      it "permits location and postal_code parameters" do
        # This would typically be tested indirectly through the controller actions
        # but we can test the method directly if needed
        params = ActionController::Parameters.new({
          location: "Boston",
          postal_code: "02101",
          authenticity_token: "token",
          forbidden_param: "should_not_pass"
        })

        allow(controller_instance).to receive(:params).and_return(params)

        result = controller_instance.send(:forecast_params)

        expect(result.keys).to contain_exactly("location", "postal_code")
        expect(result["location"]).to eq("Boston")
        expect(result["postal_code"]).to eq("02101")
      end
    end
  end

  # Integration-style tests for the full request cycle
  describe "integration behavior" do
    it "handles the complete successful forecast flow" do
      successful_forecast = {
        "current" => { "temp_f" => 65 },
        "forecast" => {
          "forecastday" => [
            { "date" => Date.today.strftime("%Y-%m-%d"), "day" => { "maxtemp_f" => 68, "mintemp_f" => 60, "condition" => { "text" => "Foggy", "icon" => "/icons/fog.png" } } }
          ]
        }
      }

      allow(Weather::ForecastService).to receive(:call).and_return(successful_forecast)

      post :update_forecast, params: {location: "San Francisco", postal_code: "94102"}, format: :turbo_stream

      expect(response).to be_successful
      expect(response.body).to include("turbo-stream")
      expect(flash[:alert]).to be_nil
    end

    it "handles the complete error forecast flow" do
      error_forecast = {
        "error" => {"message" => "Service temporarily unavailable"}
      }

      allow(Weather::ForecastService).to receive(:call).and_return(error_forecast)

      post :update_forecast, params: {location: "Invalid Location"}, format: :turbo_stream

      expect(response).to be_successful
      expect(flash[:alert]).to eq("Service temporarily unavailable")
      expect(response.body).to include("turbo-stream")
    end
  end
end

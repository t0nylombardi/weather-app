require "rails_helper"

RSpec.describe Forecast::FormComponent, type: :component do
  it "renders form with location input, postal_code hidden, and submit button" do
    result = render_inline(described_class.new)

    # form action and method
    form = result.at_css("form")
    expect(form).to be_present
    expect(form[:action]).to eq(Rails.application.routes.url_helpers.update_forecast_path)

    # location text input
    input = result.at_css("input#location")
    expect(input).to be_present
    expect(input[:name]).to eq("location")
    expect(input[:placeholder]).to include("Enter your address")

    # hidden postal_code field
    hidden = result.at_css("input[type='hidden'][name='postal_code']")
    expect(hidden).to be_present

    # submit button
    button = result.at_css("button")
    expect(button).to be_present
    expect(button["id"]).to eq("submit")
    expect(button[:type]).to eq("submit")
    expect(button.text).to include("Search")
  end
end

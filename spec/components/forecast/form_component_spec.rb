# frozen_string_literal: true

require "rails_helper"

RSpec.describe Forecast::FormComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new) }

  it "renders a form with the correct action and method" do
    form = rendered.css("form")
    expect(form.attr("action").value).to eq "/weather"
    expect(form.attr("method").value).to eq "post"
  end

  it "renders the location text field" do
    input = rendered.css("input#location")
    expect(input.attr("name").value).to eq "location"
    expect(input.attr("placeholder").value).to eq "Enter your address"
    expect(input.attr("required").value).to eq "required"
  end

  it "attaches Stimulus data attributes for address controller" do
    input = rendered.css("input#location")
    expect(input.attr("data-action").value).to include("click->address#initGoogleMaps")
    expect(input.attr("data-address-target").value).to eq "input"
  end

  it "renders a hidden field for postal_code with correct data target" do
    hidden = rendered.css("input[type='hidden'][name='postal_code']")
    expect(hidden.attr("data-address-target").value).to eq "postal_code"
  end
end

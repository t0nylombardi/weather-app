# frozen_string_literal: true

require "rails_helper"
require "ostruct"

RSpec.describe Ui::TextFieldComponent, type: :component do
  it "renders a text input with merged attributes" do
    # Minimal ActionView context for FormBuilder
    view = ActionView::Base.new(ActionController::Base.view_paths, {}, ApplicationController.new)
    form = ActionView::Helpers::FormBuilder.new(:search, OpenStruct.new, view, {})

    result = render_inline(
      described_class.new(
        form: form,
        name: :location,
        id: "location",
        placeholder: "Enter",
        required: true,
        data: { foo: "bar" },
        classes: "extra-class"
      )
    )

    input = result.at_css("input#location")
    expect(input).to be_present
    expect(input[:name]).to eq("search[location]")
    expect(input[:placeholder]).to eq("Enter")
    expect(input[:required]).to eq("required")
    expect(input["data-foo"]).to eq("bar")
    expect(input[:class]).to include("extra-class")
  end
end

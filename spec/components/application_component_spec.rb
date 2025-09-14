# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationComponent, type: :component do
  it "renders content within wrapper" do
    result = render_inline(described_class.new) { "Hello" }

    expect(result.css("div").text).to include("Hello")
  end
end

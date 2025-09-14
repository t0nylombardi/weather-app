# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ui::ButtonComponent, type: :component do
  it "renders a submit button with label and id" do
    result = render_inline(described_class.new(label: "Search", type: "submit", id: "submit"))

    button = result.at_css("button")
    expect(button).to be_present
    expect(button["id"]).to eq("submit")
    expect(button[:type]).to eq("submit")
    expect(button.text).to include("Search")
  end

  it "applies primary variant classes by default" do
    result = render_inline(described_class.new(label: "Go"))

    classes = result.at_css("button")[:class]
    expect(classes).to include("bg-lighter-rose")
    expect(classes).to include("border-text")
  end

  it "applies secondary and danger variants" do
    secondary = render_inline(described_class.new(label: "Sec", variant: :secondary))
    danger = render_inline(described_class.new(label: "Danger", variant: :danger))

    expect(secondary.at_css("button")[:class]).to include("bg-foam")
    expect(danger.at_css("button")[:class]).to include("bg-rose")
  end
end

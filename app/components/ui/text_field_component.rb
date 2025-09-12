# frozen_string_literal: true

module Ui
  # A reusable text field component for forms with Rose Pine Dawn styling.
  #
  # @param form [ActionView::Helpers::FormBuilder] the form builder (e.g. f)
  # @param name [Symbol] the attribute name (e.g. :location)
  # @param id [String, nil] optional DOM id
  # @param placeholder [String, nil] input placeholder text
  # @param required [Boolean] whether the field is required
  # @param data [Hash] stimulus/DOM data attributes
  # @param classes [String] optional additional CSS classes
  #
  # Usage:
  #   <%= render Ui::TextFieldComponent.new(form: f, name: :location,
  #          id: :location,
  #          placeholder: "Enter your address",
  #          required: true,
  #          data: { action: "click->address#initGoogleMaps", address_target: "input" }) %>
  #
  class TextFieldComponent < ViewComponent::Base
    def initialize(form:, name:, id: nil, placeholder: nil, required: false, data: {}, classes: "")
      @form = form
      @name = name
      @id = id
      @placeholder = placeholder
      @required = required
      @data = data
      @classes = classes
    end

    private

    attr_reader :form, :name, :id, :placeholder, :required, :data, :classes

    # Default Rose Pine Dawn input styles
    def base_classes
      %w[
        block w-full p-4 ps-12 text-xl
        rounded-lg border
        bg-surface text-text
        placeholder-muted
        border-overlay
        focus:ring-love focus:border-love
      ].join(" ")
    end

    def merged_classes
      [base_classes, classes].reject(&:blank?).join(" ")
    end
  end
end

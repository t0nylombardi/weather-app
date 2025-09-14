# frozen_string_literal: true

module Ui
  # A reusable button component with Rose Pine Dawn styling.
  #
  # @param label [String] text displayed inside the button
  # @param type [String] HTML button type (default: "button")
  # @param id [String, nil] optional DOM id
  # @param variant [Symbol] style variant (:primary, :secondary, :danger)
  #
  # Usage:
  #   <%= render Ui::ButtonComponent.new(label: "Search", type: "submit", id: "submit") %>
  #
  class ButtonComponent < ViewComponent::Base
    def initialize(label:, type: "button", id: nil, variant: :primary)
      @label = label
      @type = type
      @id = id
      @variant = variant
    end

    private

    attr_reader :label, :type, :id, :variant

    # Map variants to Tailwind classes using Rose Pine Dawn colors
    def variant_classes
      case variant
      when :primary
        "bg-lighter-rose hover:bg-rose text-text border border-text !rounded-full"
      when :secondary
        "bg-foam hover:bg-pine text-base"
      when :danger
        "bg-rose hover:bg-love text-base"
      when :search
        "bg-foam hover:bg-pine text-base"
      else
        "bg-surface hover:bg-overlay text-text"
      end
    end
  end
end

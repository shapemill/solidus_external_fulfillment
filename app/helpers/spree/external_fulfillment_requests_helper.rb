module Spree
  module ExternalFulfillmentRequestsHelper

    def status_field
      return "Shipped" if @fulfillment_request.state == "fulfilled"
      return @fulfillment_request.state.humanize
    end

    def should_show_instructions
      return false unless @fulfillment_request.waiting_for_fulfillment?
      return false if @fulfillment_request.fulfillment_center.fulfillment_notes.blank?
      true
    end

    def already_shipped_message
      field_text("Order has been shipped", redacted: true)
    end

    def field_text(text, redacted:, capped: false)
      text = text[0..1] + "... " if capped
      return content_tag(:span, text, class: redacted ? "text-muted" : "")
    end

    def name_field
      result = @fulfillment_request.order.shipping_address.first_name
      last_name = @fulfillment_request.order.shipping_address.last_name
      result += " " + last_name unless last_name.blank?
      field_text(
        result,
        redacted: @fulfillment_request.fulfilled?
      )
    end

    def address_field
      result = @fulfillment_request.order.shipping_address.address1
      address2 = @fulfillment_request.order.shipping_address.address2
      result += ", " + address2 unless address2.blank?
      field_text(
        result,
        redacted: @fulfillment_request.fulfilled?
      )
    end

    def city_field
      field_text(
        @fulfillment_request.order.shipping_address.city,
        redacted: @fulfillment_request.fulfilled?
      )
    end

    def state_field
      field_text(
        @fulfillment_request.order.shipping_address.state,
        redacted: @fulfillment_request.fulfilled?
      )
    end

    def zip_code_field
      field_text(
        @fulfillment_request.order.shipping_address.zipcode,
        redacted: @fulfillment_request.fulfilled?
      )
    end

    def country_field
      field_text(
        @fulfillment_request.order.shipping_address.country,
        redacted: @fulfillment_request.fulfilled?
      )
    end

    def shipping_method_field
      return already_shipped_message if @fulfillment_request.fulfilled?
      @fulfillment_request.order.shipments.first.shipping_method.name
    end

    def packing_slip_link
      return already_shipped_message if @fulfillment_request.fulfilled?
      return "None" if @fulfillment_request.packing_slip_url.nil?
      link_to(
        "Download",
        @fulfillment_request.packing_slip_url,
        class: "btn-sm btn-primary"
      )
    end

    def print_dimensions_string(instruction)
      variant = instruction.line_item.variant
      variant.option_values.each do |option_value|
        if option_value.option_type.print_dimensions?
          return "#{option_value.width_mm} x #{option_value.height_mm} mm"
        end
      end
    end

    def paper_type_string(instruction)
      variant = instruction.line_item.variant
      variant.option_values.each do |option_value|
        if option_value.option_type.paper_type?
          return option_value.presentation
        end
      end
    end
  end
end
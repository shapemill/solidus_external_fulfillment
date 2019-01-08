module Spree
  module ExternalFulfillmentRequestsHelper
    def status_field
      return "Shipped" if @fulfillment_request.state == "fulfilled"
      @fulfillment_request.state.humanize
    end

    def should_show_instructions
      return false unless @fulfillment_request.waiting_for_fulfillment?
      return false if @fulfillment_request.fulfillment_center.fulfillment_notes.blank?
      true
    end

    def redact_sensitive_fulfillment_request_info
      unless @fulfillment_request.fulfillment_center.enable_order_page_http_auth?
        return @fulfillment_request.fulfilled?
      end
      false
    end

    def already_shipped_message
      field_text("Order has been shipped")
    end

    def field_text(text, sensitive: false)
      text = text[0..1] + "... " if sensitive && redact_sensitive_fulfillment_request_info
      text
    end

    def name_field
      result = @fulfillment_request.order.shipping_address.first_name
      last_name = @fulfillment_request.order.shipping_address.last_name
      result += " " + last_name unless last_name.blank?
      field_text(
        result, sensitive: true
      )
    end

    def address_field
      result = @fulfillment_request.order.shipping_address.address1
      address2 = @fulfillment_request.order.shipping_address.address2
      result += ", " + address2 unless address2.blank?
      field_text(
        result, sensitive: true
      )
    end

    def city_field
      field_text(
        @fulfillment_request.order.shipping_address.city,
        sensitive: true
      )
    end

    def state_field
      field_text(
        @fulfillment_request.order.shipping_address.state
      )
    end

    def zip_code_field
      field_text(
        @fulfillment_request.order.shipping_address.zipcode,
        sensitive: true
      )
    end

    def country_field
      field_text(
        @fulfillment_request.order.shipping_address.country
      )
    end

    def shipping_method_field
      return already_shipped_message if @fulfillment_request.fulfilled?
      @fulfillment_request.order.shipments.first.shipping_method.name
    end

    def packing_slip_link
      return already_shipped_message if redact_sensitive_fulfillment_request_info
      return "None" if @fulfillment_request.packing_slip_url.nil?
      link_to(
        "Download",
        @fulfillment_request.packing_slip_url,
        class: "btn-sm btn-primary",
        target: "_blank"
      )
    end
  end
end

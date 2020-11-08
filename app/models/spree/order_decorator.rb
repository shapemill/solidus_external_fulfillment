module Spree
  module OrderDecorator
    # TODO: make this an association
    def fulfillment_requests
      Spree::FulfillmentRequest.where(order: self)
    end

    def ship_line_items_with_no_fulfillment_center(tracking_number)
      shipment = shipments.first
      inventory_units = []
      line_items_with_no_fulfillment_center.each do |line_item|
        inventory_units += line_item.inventory_units
      end

      shipping.ship(
        inventory_units: inventory_units,
        stock_location: shipment.stock_location,
        address: shipping_address,
        shipping_method: shipment.shipping_method,
        tracking_number: tracking_number
      )
    end

    def line_items_with_no_fulfillment_center
      result = []
      line_items.each do |line_item|
        fulfillment_center = line_item.assigned_fulfillment_center
        result << line_item if fulfillment_center.nil?
      end
      result
    end
  end
end

Spree::Order.prepend Spree::OrderDecorator

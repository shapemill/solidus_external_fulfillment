module Spree
  module OrderDecorator
    # Called after an order has been completed.
    def finalize!
      # First call super
      super

      # Create a list of unique ids of fulfillment centers
      # associated with this order
      fulfillment_center_ids = []
      line_items.each do |line_item|
        fulfillment_center = line_item.assigned_fulfillment_center
        next if fulfillment_center.nil?
        center_id = fulfillment_center.id
        next if fulfillment_center_ids.include?(center_id)
        fulfillment_center_ids << center_id
      end

      # For each unique fulfillment center, create a blank fulfillment request
      Spree::FulfillmentRequest.transaction do
        fulfillment_center_ids.each do |fulfillment_center_id|
          next if fulfillment_center_id.nil?

          Spree::FulfillmentRequest.create({
            spree_fulfillment_center_id: fulfillment_center_id,
            order: self
          })
        end
      end
    end

    # TODO: make this an association
    def fulfillment_requests
      Spree::FulfillmentRequest.where(order: self)
    end

    def ship_line_items_with_no_fulfillment_center(tracking_number)
      shipment = shipments.first
      shipping.ship(
        inventory_units: line_items_with_no_fulfillment_center.map { |l| l.inventory_units.first },
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

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
        fulfillment_center = fulfillment_center_for_line_item(line_item)
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

    def fulfillment_requests
      Spree::FulfillmentRequest.where(order: self)
    end

    def line_items_with_no_fulfillment_center
      result = []
      line_items.each do |line_item|
        fulfillment_center = fulfillment_center_for_line_item(line_item)
        result << fulfillment_center if fulfillment_center.nil?
      end
      result
    end

    def fulfillment_center_for_line_item(line_item)
      class_name = Spree::ExternalFulfillment.fulfillment_center_assigner_class
      assigner = class_name.constantize.new(line_item)
      assigner.fulfillment_center
    end
  end
end

Spree::Order.prepend Spree::OrderDecorator

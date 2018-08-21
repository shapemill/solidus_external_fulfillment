class Spree::DefaultFulfillmentCenterAssigner
  def initialize(line_item)
    @line_item = line_item
  end

  def fulfillment_center
    product_fulfillment_type = @line_item.product.fulfillment_type
    return if product_fulfillment_type.nil?

    Spree::FulfillmentCenter.default_for product_fulfillment_type
  end
end

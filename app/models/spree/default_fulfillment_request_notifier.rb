class Spree::DefaultFulfillmentRequestNotifier
  def initialize(fulfillment_request)
    @fulfillment_request = fulfillment_request
  end

  def created
    # puts "Spree::DefaultFulfillmentRequestNotifier: fulfillment request created"
  end

  def fulfilled
    # puts "Spree::DefaultFulfillmentRequestNotifier: fulfillment request fulfilled"
  end

  def prepared
    # puts "Spree::DefaultFulfillmentRequestNotifier: fulfillment request prepared"
  end

  def failed_to_prepare
    # puts "Spree::DefaultFulfillmentRequestNotifier: fulfillment request failed to prepare"
  end
end

class Spree::DefaultPackingSlipProvider
  def initialize(fulfillment_request)
    @fulfillment_request = fulfillment_request
  end

  def packing_slip_url
    nil
  end
end

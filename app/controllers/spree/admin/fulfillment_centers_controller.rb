class Spree::Admin::FulfillmentCentersController < Spree::Admin::ResourceController
  def index
    @fulfillment_centers = Spree::FulfillmentCenter.all.order(:display_name)
  end
end

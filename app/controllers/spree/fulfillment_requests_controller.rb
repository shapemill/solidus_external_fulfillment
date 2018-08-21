class Spree::FulfillmentRequestsController < ApplicationController
  layout 'fulfillment_request'

  def show
    @fulfillment_request = Spree::FulfillmentRequest.find_by_hash_id(
      params[:hash_id]
    )
  end

  def fulfill
    @fulfillment_request = Spree::FulfillmentRequest.find_by_hash_id(
      params[:hash_id]
    )
    @fulfillment_request.fulfill!
    redirect_to fulfillment_request_url(@fulfillment_request.hash_id)
  end
end

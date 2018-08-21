# Handles routes outside of the Spree admin scope meant to be accessed
# by external fulfillment centers
class Spree::ExternalFulfillmentRequestsController < ApplicationController
  layout 'external_fulfillment_request'

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
    redirect_to external_fulfillment_request_url(@fulfillment_request.hash_id)
  end
end

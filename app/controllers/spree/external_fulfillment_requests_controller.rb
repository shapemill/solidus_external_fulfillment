# Handles routes outside of the Spree admin scope meant to be accessed
# by external fulfillment centers
class Spree::ExternalFulfillmentRequestsController < ApplicationController
  layout 'external_fulfillment_request'

  before_action :set_fulfillment_request
  before_action :http_authenticate

  def http_authenticate
    fulfillment_center = @fulfillment_request.fulfillment_center
    return true if !fulfillment_center.enable_order_page_http_auth

    username = fulfillment_center.order_page_username
    password = fulfillment_center.order_page_password
    authenticate_or_request_with_http_basic do |entered_username, entered_password|
      entered_username == username && entered_password == password
    end
  end

  def set_fulfillment_request
    @fulfillment_request = Spree::FulfillmentRequest.find_by_hash_id(
      params[:hash_id]
    )
  end

  def show
    #
  end

  def fulfill
    @fulfillment_request = Spree::FulfillmentRequest.find_by_hash_id(
      params[:hash_id]
    )
    @fulfillment_request.fulfill_with_tracking_number(params[:tracking_number])
    redirect_to external_fulfillment_request_url(@fulfillment_request.hash_id)
  end
end

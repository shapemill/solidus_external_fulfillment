class Spree::Admin::FulfillmentRequestsController < Spree::Admin::BaseController
  def start_preparation
    @fulfillment_request = Spree::FulfillmentRequest.find params[:id]
    @fulfillment_request.start_preparation!
    redirect_to edit_admin_order_url(@fulfillment_request.order)
  end

  def reset
    @fulfillment_request = Spree::FulfillmentRequest.find params[:id]
    @fulfillment_request.reset!
    redirect_to edit_admin_order_url(@fulfillment_request.order)
  end

  def resend
    @fulfillment_request = Spree::FulfillmentRequest.find params[:id]
    Spree::FulfillmentRequestMailer.with(fulfillment_request: @fulfillment_request).fulfillment_request_email.deliver_later
    # TODO: set flash?
    redirect_to edit_admin_order_url(@fulfillment_request.order)
  end
end

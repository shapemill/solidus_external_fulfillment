module Spree
  class FulfillmentRequestMailer < ApplicationMailer
    def fulfillment_request_email
      @fulfillment_request = params[:fulfillment_request]
      fulfillment_center = @fulfillment_request.fulfillment_center
      order = @fulfillment_request.order
      store = order.store
      mail(
        to: fulfillment_center.order_email,
        from: store.mail_from_address,
        subject: "Order #{order.number} from #{store.name}"
      )
    end
  end
end

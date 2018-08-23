module Spree
  module Admin
    module OrdersControllerDecorator
      def ship_items_with_no_fulfillment_center
        order = Spree::Order.find_by(number: params[:id])
        tracking_number = params[:tracking_number]
        order.ship_line_items_with_no_fulfillment_center(tracking_number)
        redirect_to edit_admin_order_url(order)
      end
    end
  end
end

Spree::Admin::OrdersController.prepend Spree::Admin::OrdersControllerDecorator

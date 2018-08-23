class AddFulfillmentRequestToCartons < ActiveRecord::Migration[5.2]
  def change
    add_reference :spree_cartons, :spree_fulfillment_request
  end
end

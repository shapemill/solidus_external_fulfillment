class CreateSpreeFulfillmentRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :spree_fulfillment_requests do |t|
      t.integer :state, null: false
      t.text :preparation_error
      t.text :packing_slip_url
      t.datetime :fulfilled_at
      t.timestamps
    end

    add_reference :spree_fulfillment_requests, :spree_order
    add_reference :spree_fulfillment_requests, :spree_fulfillment_center, index: { name: 'index_spree_fulfillment_reqs_on_spree_fulfillment_ctr_id' }
  end
end

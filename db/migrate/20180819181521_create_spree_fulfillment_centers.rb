class CreateSpreeFulfillmentCenters < ActiveRecord::Migration[5.2]
  def change
    create_table :spree_fulfillment_centers do |t|
      t.integer :fulfillment_type, null: false
      t.boolean :is_default_for_fulfillment_type, null: false, default: false
      t.boolean :enable_order_page_http_auth, null: false, default: false
      t.text :order_page_username
      t.text :order_page_password
      t.text :display_name, null: false
      t.text :order_email, null: false
      t.text :fulfillment_notes
      t.integer :batch_fulfillment_cost_threshold, default: 0, null: false
      t.integer :batch_fulfillment_time_threshold, default: 0, null: false
      t.datetime :latest_batch_fulfillment_job_at

      t.timestamps
    end
  end
end

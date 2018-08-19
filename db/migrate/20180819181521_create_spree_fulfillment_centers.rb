class CreateSpreeFulfillmentCenters < ActiveRecord::Migration[5.2]
  def change
    create_table :spree_fulfillment_centers do |t|
      t.integer :fulfillment_type, null: false
      t.boolean :is_default_for_fulfillment_type, null: false, default: false
      t.text :display_name, null: false
      t.text :order_email, null: false
      t.text :fulfillment_notes

      t.timestamps
    end
  end
end

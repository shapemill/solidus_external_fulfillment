class AddFulfillmentTypeToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_products, :fulfillment_type, :integer
  end
end

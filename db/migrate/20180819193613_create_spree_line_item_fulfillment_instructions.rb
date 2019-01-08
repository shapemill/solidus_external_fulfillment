class CreateSpreeLineItemFulfillmentInstructions < ActiveRecord::Migration[5.2]
  def change
    create_table :spree_line_item_fulfillment_instructions do |t|
    end

    add_reference :spree_line_item_fulfillment_instructions, :spree_fulfillment_request, index: { name: 'spree_line_item_fullfilment_instr_request_idx' }
    add_reference :spree_line_item_fulfillment_instructions, :spree_line_item, index: { name: 'spree_line_item_fullfilment_instr_line_item_idx' }
  end
end

class Spree::LineItemFulfillmentInstruction < ApplicationRecord
  belongs_to :line_item, class_name: "Spree::LineItem", foreign_key: "spree_line_item_id"
  belongs_to :fulfillment_request, class_name: "Spree::FulfillmentRequest", foreign_key: "spree_fulfillment_request_id"

  validates :fulfillment_request, presence: true
  validates :line_item, presence: true
end

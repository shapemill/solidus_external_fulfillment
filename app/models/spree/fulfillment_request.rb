class Spree::FulfillmentRequest < ApplicationRecord
  enum state: [
    :not_prepared,
    :preparing,
    :pending,
    :fulfilled,
    :preparation_failed
  ]

  belongs_to :order, class_name: "Spree::Order", foreign_key: "spree_order_id"
  belongs_to :fulfillment_center, class_name: "Spree::FulfillmentCenter", foreign_key: "spree_fulfillment_center_id"
  has_many :line_item_fulfillment_instructions, class_name: "Spree::LineItemFulfillmentInstruction", foreign_key: "spree_fulfillment_request_id"

  validates :fulfillment_center, presence: true
  validates :order, presence: true
  validates :state, presence: true

  state_machine :state, initial: :not_prepared do
    event :start_preparation do
      transition not_prepared: :preparing
    end

    event :fail_preparation do
      transition preparing: :preparation_failed
    end

    event :finish_preparation do
      transition preparing: :pending
    end

    event :fulfill do
      transition pending: :fulfilled
    end

    event :reset do
      transition [:pending, :preparation_failed, :fulfilled] => :not_prepared
    end
  end

  def self.find_by_hash_id(obfuscated_id)
    id = id_hasher.decode(obfuscated_id).first
    Spree::FulfillmentRequest.find(id)
  end

  def hash_id
    Spree::FulfillmentRequest.id_hasher.encode(id)
  end

  def self.id_hasher
    ::Hashids.new(
      "0c0daa78aeec13154c0830e5f6cf44",
      16
    )
  end
end

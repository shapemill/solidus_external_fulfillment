class Spree::FulfillmentRequest < ApplicationRecord
  enum state: [
    :waiting_for_preparation,
    :preparing,
    :waiting_for_fulfillment,
    :fulfilled,
    :preparation_failed
  ]

  after_create do
    notifier.created
  end

  belongs_to :order, class_name: "Spree::Order", foreign_key: "spree_order_id"
  belongs_to :fulfillment_center, class_name: "Spree::FulfillmentCenter", foreign_key: "spree_fulfillment_center_id"
  has_many :line_item_fulfillment_instructions, class_name: "Spree::LineItemFulfillmentInstruction", foreign_key: "spree_fulfillment_request_id"

  validates :fulfillment_center, presence: true
  validates :order, presence: true
  validates :state, presence: true

  state_machine :state, initial: :waiting_for_preparation do
    event :start_preparation do
      transition waiting_for_preparation: :preparing
    end

    event :fail_preparation do
      transition preparing: :preparation_failed
    end

    event :finish_preparation do
      transition preparing: :waiting_for_fulfillment
    end

    event :fulfill do
      transition waiting_for_fulfillment: :fulfilled
    end

    event :reset do
      transition [:waiting_for_fulfillment, :preparation_failed, :fulfilled] => :waiting_for_preparation
    end

    after_transition to: :not_preared do |fulfillment_request, _|
      # Destroy any referencing line items when transitioning back to waiting_for_preparation
      fulfillment_request.line_item_fulfillment_instructions.destroy_all
    end

    after_transition to: :waiting_for_fulfillment do |fulfillment_request, _|
      # Call the custom notifier
      fulfillment_request.notifier.prepared
      # Send notification email to the fulfillment center
      Spree::FulfillmentRequestMailer.with(fulfillment_request: fulfillment_request).fulfillment_request_email.deliver_later
    end

    after_transition to: :preparing do |fulfillment_request, _|
      fulfillment_request.start_preparation_job(fulfillment_request)
    end

    after_transition to: :fulfilled do |fulfillment_request, _|
      fulfillment_request.notifier.fulfilled
      fulfillment_request.fulfilled_at = DateTime.now
      fulfillment_request.save!
    end

    after_transition to: :fail_preparation do |fulfillment_request, _|
      fulfillment_request.notifier.failed_to_prepare
    end
  end

  def self.find_by_hash_id(hash_id)
    id = id_hasher.decode(hash_id).first
    Spree::FulfillmentRequest.find(id)
  end

  def hash_id
    Spree::FulfillmentRequest.id_hasher.encode(id)
  end

  def self.id_hasher
    ::Hashids.new(
      Spree::ExternalFulfillment.hash_id_salt,
      16
    )
  end

  def self.create_on_order_finalized(order)
    # Create a list of unique ids of fulfillment centers
    # associated with this order
    fulfillment_center_ids = []
    order.line_items.each do |line_item|
      fulfillment_center = line_item.assigned_fulfillment_center
      next if fulfillment_center.nil?
      center_id = fulfillment_center.id
      next if fulfillment_center_ids.include?(center_id)
      fulfillment_center_ids << center_id
    end

    # For each unique fulfillment center, create a blank fulfillment request
    Spree::FulfillmentRequest.transaction do
      fulfillment_center_ids.each do |fulfillment_center_id|
        next if fulfillment_center_id.nil?

        Spree::FulfillmentRequest.create({
          spree_fulfillment_center_id: fulfillment_center_id,
          order: order
        })
      end
    end
  end

  def notifier
    class_name = Spree::ExternalFulfillment.fulfillment_request_notifier_class
    class_name.constantize.new(self)
  end

  def start_preparation_job(fulfillment_request)
    Spree::FulfillmentRequestPreparationJob.perform_later(fulfillment_request)
  end

  def line_items
    result = []
    order.line_items.each do |line_item|
      if line_item.product.fulfillment_type == fulfillment_center.fulfillment_type
        result << line_item
      end
    end
    result
  end

  def fulfill_with_tracking_number(tracking_number)
    shipment = order.shipments.first
    inventory_units = []
    line_items.each do |line_item|
      inventory_units += line_item.inventory_units
    end
    carton = order.shipping.ship(
      inventory_units: inventory_units,
      stock_location: shipment.stock_location,
      address: order.shipping_address,
      shipping_method: shipment.shipping_method,
      tracking_number: tracking_number
    )
    carton.fulfillment_request = self
    carton.save!
    fulfill!
  end
end

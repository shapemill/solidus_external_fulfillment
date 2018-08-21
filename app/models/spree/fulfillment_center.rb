class Spree::FulfillmentCenter < ApplicationRecord

  # This enum is defined during engine initialization
  # enum fulfillment_type

  validates :fulfillment_type, presence: true
  validates :is_default_for_fulfillment_type, inclusion: [true, false]
  validates :display_name, presence: true
  validates :display_name, presence: true
  validates :order_email, presence: true

  before_save do
    refresh_default_flags
  end

  def self.default_for(fulfillment_type)
    Spree::FulfillmentCenter.find_by(
      fulfillment_type: fulfillment_type,
      is_default_for_fulfillment_type: true
    )
  end

  private

  def refresh_default_flags
    if Spree::FulfillmentCenter.default_for(fulfillment_type).nil?
      self.is_default_for_fulfillment_type = true
    elsif is_default_for_fulfillment_type
      # ... and this record is the default.
      # clear default flag on all other records
      Spree::FulfillmentCenter.where.not(
        id: id
      ).update_all(
        is_default_for_fulfillment_type: false
      )
    else
      other_records = Spree::FulfillmentCenter.where.not(
        id: id
      ).where(
        fulfillment_type: fulfillment_type,
        is_default_for_fulfillment_type: true
      )
      if other_records.empty?
        self.is_default_for_fulfillment_type = true
      end
    end
  end
end

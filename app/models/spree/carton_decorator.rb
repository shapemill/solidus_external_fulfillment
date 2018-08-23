module Spree
  module CartonDecorator
    def self.prepended(base)
      base.belongs_to :fulfillment_request, class_name: 'Spree::FulfillmentRequest', foreign_key: "spree_fulfillment_request_id"
    end
  end
end

Spree::Carton.prepend Spree::CartonDecorator

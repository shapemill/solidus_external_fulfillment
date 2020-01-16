module Spree
  module CartonDecorator
    def self.prepended(base)
      # Changed to optional due to https://github.com/solidusio/solidus/pull/3309
      base.belongs_to :fulfillment_request, class_name: 'Spree::FulfillmentRequest', foreign_key: "spree_fulfillment_request_id", optional: true
    end
  end
end

Spree::Carton.prepend Spree::CartonDecorator

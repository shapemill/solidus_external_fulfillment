module Spree
  module ProductDecorator
    def self.prepended(base)
      base.enum fulfillment_type: Spree::ExternalFulfillment.fulfillment_types
    end
  end
end

Spree::Product.prepend Spree::ProductDecorator

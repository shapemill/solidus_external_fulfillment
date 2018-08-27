module Spree
  module VariantDecorator
    def should_track_inventory?
      return super if product.fulfillment_type.nil?

      # Don't track inventory for variants of products
      # that require external fulfillment
      false
    end
  end
end

Spree::Variant.prepend Spree::VariantDecorator

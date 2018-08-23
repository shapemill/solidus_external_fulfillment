module Spree
  module LineItemDecorator
    def assigned_fulfillment_center
      class_name = Spree::ExternalFulfillment.fulfillment_center_assigner_class
      assigner = class_name.constantize.new(self)
      assigner.fulfillment_center
    end
  end
end

Spree::LineItem.prepend Spree::LineItemDecorator

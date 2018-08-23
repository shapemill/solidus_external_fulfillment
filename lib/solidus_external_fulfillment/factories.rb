FactoryBot.define do
  # Define your Spree extensions Factories within this file to enable applications, and other extensions to use and override them.
  #
  # Example adding this to your spec_helper will load these Factories for use:
  # require 'solidus_external_fulfillment/factories'

  factory :spree_fulfillment_center, class: 'Spree::FulfillmentCenter' do
    fulfillment_type { :dummy_type_1 }
    display_name { "Test center" }
    order_email { "test@example.com" }
  end

  factory :spree_fulfillment_request, class: 'Spree::FulfillmentRequest' do
    state { :not_prepared }
    association :order, factory: :order_ready_to_ship
    association :fulfillment_center, factory: :spree_fulfillment_center
  end

  factory :order_with_many_fulfillment_types, parent: :order_ready_to_complete do
    transient do
      line_items_count {
        10
      }
    end

    after(:create) do |order, evaluator|
      fulfillment_types_and_nil = Spree::ExternalFulfillment.fulfillment_types + [nil]
      order.line_items.each_with_index do |line_item, index|
        fulfillment_type = fulfillment_types_and_nil[index % fulfillment_types_and_nil.length]
        line_item.product.fulfillment_type = fulfillment_type
        line_item.product.save!
        Spree::FulfillmentCenter.create({
          display_name: "Hello",
          order_email: "a@b.c",
          fulfillment_type: fulfillment_type
        })
      end
    end
  end
end

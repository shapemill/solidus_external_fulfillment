FactoryBot.define do
  # Define your Spree extensions Factories within this file to enable applications, and other extensions to use and override them.
  #
  # Example adding this to your spec_helper will load these Factories for use:
  # require 'solidus_external_fulfillment/factories'

  factory :spree_fulfillment_center, class: 'Spree::FulfillmentCenter' do
    fulfillment_type { :paper_print }
    display_name { "Test center" }
    order_email { "test@example.com" }
  end

  factory :spree_fulfillment_request, class: 'Spree::FulfillmentRequest' do
    state :not_prepared
    association :order, factory: :order_ready_to_ship
    association :fulfillment_center, factory: :spree_fulfillment_center
  end
end

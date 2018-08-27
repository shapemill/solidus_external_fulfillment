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

  factory :fulfillment_request, class: 'Spree::FulfillmentRequest' do
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

    after(:create) do |order, _|
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

  factory :order_with_many_fulfillment_types_ready_to_ship, parent: :order_with_many_fulfillment_types do
    transient do
      payment_type :credit_card_payment
    end

    after(:create) do |order, evaluator|
      order.complete!

      create(evaluator.payment_type, amount: order.total, order: order, state: 'completed')
      order.shipments.each do |shipment|
        shipment.update_column('state', 'ready')
      end
      order.reload
    end
  end

  factory :periodic_fulfillment_preparation_job_invocation, class: 'Spree::PeriodicFulfillmentPreparationJobInvocation' do

  end

  factory :finished_periodic_fulfillment_preparation_job_invocation, class: 'Spree::PeriodicFulfillmentPreparationJobInvocation' do
    state :finished
    running_time 5.5
  end

  factory :failed_periodic_fulfillment_preparation_job_invocation, class: 'Spree::PeriodicFulfillmentPreparationJobInvocation' do
    state :failed
    error_message "test error message"
  end
end

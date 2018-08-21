Spree::ExternalFulfillment.fulfillment_types = [:dummy_type_1, :dummy_type_2]
Rails.application.config.assets.precompile += %w( external_fulfillment_request.css )
Spree::ExternalFulfillment.fulfillment_request_notifier_class = "Spree::DefaultFulfillmentRequestNotifier"

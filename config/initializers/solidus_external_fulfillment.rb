Rails.application.config.assets.precompile += %w( external_fulfillment_request.css )

Spree::ExternalFulfillment.periodic_fulfillment_notifier_class = "Spree::DefaultPeriodicFulfillmentNotifierClass"
Spree::ExternalFulfillment.fulfillment_request_notifier_class = "Spree::DefaultFulfillmentRequestNotifier"
Spree::ExternalFulfillment.fulfillment_center_assigner_class = "Spree::DefaultFulfillmentCenterAssigner"
Spree::ExternalFulfillment.line_item_fullfillment_instruction_builder_class = "Spree::DefaultLineItemFulfillmentInstructionBuilder"

# Override this in apps using the extension
Spree::ExternalFulfillment.fulfillment_types = [:dummy_type_1, :dummy_type_2]

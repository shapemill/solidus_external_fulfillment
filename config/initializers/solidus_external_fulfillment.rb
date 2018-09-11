Rails.application.config.assets.precompile += %w( external_fulfillment_request.css )

Spree::ExternalFulfillment.queue_jobs_as = :default
Spree::ExternalFulfillment.packing_slip_provider_class = "Spree::DefaultPackingSlipProvider"
Spree::ExternalFulfillment.batch_fulfillment_notifier_class = "Spree::DefaultPeriodicFulfillmentNotifier"
Spree::ExternalFulfillment.fulfillment_request_notifier_class = "Spree::DefaultFulfillmentRequestNotifier"
Spree::ExternalFulfillment.fulfillment_center_assigner_class = "Spree::DefaultFulfillmentCenterAssigner"
Spree::ExternalFulfillment.line_item_fullfillment_instruction_builder_class = "Spree::DefaultLineItemFulfillmentInstructionBuilder"
Spree::ExternalFulfillment.batch_fulfillment_checker_class = "Spree::DefaultPeriodicFulfillmentChecker"
Spree::ExternalFulfillment.hash_id_salt = "0c0daa78aeec13154c0830e5f6cf44"

# Override this in apps using the extension
Spree::ExternalFulfillment.fulfillment_types = [:dummy_type_1, :dummy_type_2, :dummy_type_3, :dummy_type_4]

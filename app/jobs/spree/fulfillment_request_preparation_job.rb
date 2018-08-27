class Spree::FulfillmentRequestPreparationJob < ApplicationJob
  queue_as :default

  def perform(fulfillment_request)
    fulfillment_request.with_lock do
      process_line_items(fulfillment_request)
    end
  rescue Spree::FulfillmentRequestAlreadyPreparedError => e
    # Silently ignore attempts to prepare already prepared
    # fulfillment requests. This may happen when the same request
    # is being prepared concurrently from different threads
  rescue StandardError => e
    # Something went wrong
    fulfillment_request.preparation_error = e.message
    fulfillment_request.fail_preparation!
  end

  def process_line_items(fulfillment_request)
    if fulfillment_request.waiting_for_fulfillment? || fulfillment_request.fulfilled? || fulfillment_request.preparation_failed?
      raise Spree::FulfillmentRequestAlreadyPreparedError.new(
        "Attempting to re-prepare fulfillment request in state #{fulfillment_request.state}"
      )
    end

    if !fulfillment_request.preparing?
      raise Spree::ExternalFulfillmentError.new(
        "Expected fulfillment request in preparing state when starting fulfillment job"
      )
    end

    line_items = fulfillment_request.line_items

    if line_items.empty?
      raise Spree::ExternalFulfillmentError.new(
        "Attempting to prepare a fulfillment request with no associated line items"
      )
    end

    # Iterate over the request's line items
    line_items.each do |line_item|
      # Create a new instruction for this line item
      line_item_instruction = Spree::LineItemFulfillmentInstruction.new({
        line_item: line_item,
        fulfillment_request: fulfillment_request
      })
      # Call customizable hook for preparing the instructions
      build_instructions(line_item_instruction)
      # Save the instructions
      line_item_instruction.save!
      fulfillment_request.line_item_fulfillment_instructions << line_item_instruction
    end

    # Generate packing slip through customizable hook
    fulfillment_request.packing_slip_url = packing_slip_url(fulfillment_request)

    fulfillment_request.finish_preparation!
  end

  def build_instructions(line_item_fulfillment_instructions)
    instruction_builder_class_name = Spree::ExternalFulfillment.line_item_fullfillment_instruction_builder_class
    instruction_builder = instruction_builder_class_name.constantize.new(
      line_item_fulfillment_instructions
    )
    instruction_builder.build
  end

  def packing_slip_url(fulfillment_request)
    packing_slip_provider_class_name = Spree::ExternalFulfillment.packing_slip_provider_class
    provider = packing_slip_provider_class_name.constantize.new(fulfillment_request)
    provider.packing_slip_url
  end
end

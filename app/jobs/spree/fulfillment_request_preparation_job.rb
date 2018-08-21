class Spree::FulfillmentRequestPreparationJob < ApplicationJob
  queue_as :default

  def perform(fulfillment_request)
    fulfillment_request.with_lock do
      raise "Expected fulfillment request in preparing state" if !fulfillment_request.preparing? # TODO: error type

      fulfillment_request.line_items.each do |line_item|
        line_item_instruction = Spree::LineItemFulfillmentInstruction.new({
          line_item: line_item,
          fulfillment_request: fulfillment_request
        })
        build_instructions(line_item_instruction)
        line_item_instruction.save!
        fulfillment_request.line_item_fulfillment_instructions << line_item_instruction
      end

      fulfillment_request.finish_preparation!
      fulfillment_request.save!
    end
    # TODO: catch errors and
    # fulfillment_request.fail_preparation!
  end

  def build_instructions(line_item_fulfillment_instructions)
    instruction_builder_class_name = Spree::ExternalFulfillment.line_item_fullfillment_instruction_builder_class
    instruction_builder = instruction_builder_class_name.constantize.new(
      line_item_fulfillment_instructions
    )
    instruction_builder.build
  end

end

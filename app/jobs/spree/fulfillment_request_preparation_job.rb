class Spree::FulfillmentRequestPreparationJob < ApplicationJob
  queue_as :default

  def perform(fulfillment_request)
    fulfillment_request.with_lock do
      fulfillment_request.start_preparation!

      line_items = []
      line_items.each do |line_item|
        line_item_instruction = LineItemFulfillmentInstruction.new({
          line_item: line_item,
          fulfillment_request: fulfillment_request
        })

        # TODO: custom further processing of line_item_instruction

        line_item_instruction.save!
        fulfillment_request.line_item_fulfillment_instructions << line_item_instruction
      end

      fulfillment_request.finish_preparation!
      fulfillment_request.save!
    end

    # TODO: catch errors and
    fulfillment_request.fail_preparation!
  end
end

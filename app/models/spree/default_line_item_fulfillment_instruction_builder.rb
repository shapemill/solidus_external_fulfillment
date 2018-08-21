class Spree::DefaultLineItemFulfillmentInstructionBuilder
  def initialize(line_item_fulfillment_instruction)
    @line_item_fulfillment_instruction = line_item_fulfillment_instruction
  end

  def build
    puts "Spree::DefaultLineItemFulfillmentInstructionBuilder: Preparing to do work"
    sleep 2
    puts "Spree::DefaultLineItemFulfillmentInstructionBuilder: Done preparing!"
  end

end

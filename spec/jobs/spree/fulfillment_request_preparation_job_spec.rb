require 'spec_helper'

class PackingSlipProvider
  def initialize(fulfillment_request)
    @fulfillment_request = fulfillment_request
  end

  def packing_slip_url
    "test_packing_slip_url"
  end
end

class LineItemFulfillmentInstructionBuilder
  def initialize(line_item_fulfillment_instruction)
    @line_item_fulfillment_instruction = line_item_fulfillment_instruction
  end

  def build
    #
  end
end

class FailingLineItemFulfillmentInstructionBuilder
  def initialize(line_item_fulfillment_instruction)
    @line_item_fulfillment_instruction = line_item_fulfillment_instruction
  end

  def build
    raise StandardError.new("omgfailure")
  end
end

RSpec.describe Spree::FulfillmentRequestPreparationJob, type: :job do
  include ActiveJob::TestHelper

  before do
    Spree::ExternalFulfillment.line_item_fullfillment_instruction_builder_class = "LineItemFulfillmentInstructionBuilder"
  end

  subject(:job) { Spree::FulfillmentRequestPreparationJob.new }

  before(:each) do
    @fulfillment_request = FactoryBot.create(:fulfillment_request)
    @fulfillment_request.order.line_items.each do |line_item|
      line_item.product.fulfillment_type = @fulfillment_request.fulfillment_center.fulfillment_type
      line_item.product.save!
    end
    @fulfillment_request.start_preparation!
  end

  describe "performing job" do
    describe "a second time" do
      it "does not create additional instructions" do
        job.perform(@fulfillment_request)
        instruction_count = @fulfillment_request.line_item_fulfillment_instructions.count
        @fulfillment_request.reset!
        @fulfillment_request.start_preparation!
        job.perform(@fulfillment_request)
        expect(instruction_count).to eq(@fulfillment_request.line_item_fulfillment_instructions.count)
      end
    end

    describe "with a failing instruction builder" do
      before(:each) do
        Spree::ExternalFulfillment.line_item_fullfillment_instruction_builder_class = "FailingLineItemFulfillmentInstructionBuilder"
        job.perform(@fulfillment_request)
      end

      it "puts the request in a preparation_failed state" do
        expect(@fulfillment_request.preparation_failed?).to eq(true)
      end

      it "stores the error message in the request" do
        expect(@fulfillment_request.preparation_error).to eq("omgfailure")
      end

      it "creates no line item instructions" do
        expect(@fulfillment_request.line_item_fulfillment_instructions).to be_empty
      end
    end

    describe "with a working instruction builder" do
      before(:each) do
        Spree::ExternalFulfillment.line_item_fullfillment_instruction_builder_class = "LineItemFulfillmentInstructionBuilder"
        job.perform(@fulfillment_request)
      end

      it "puts the request in a waiting_for_fulfillment state" do
        expect(@fulfillment_request.waiting_for_fulfillment?).to eq(true)
      end

      it "creates one line item instruction per line item" do
        expect(@fulfillment_request.line_items.length).to eq(@fulfillment_request.line_item_fulfillment_instructions.count)
      end
    end

    describe "with the default packing slip provider" do
      before(:each) do
        Spree::ExternalFulfillment.packing_slip_provider_class = "Spree::DefaultPackingSlipProvider"
        job.perform(@fulfillment_request)
      end

      it "does not set the packing slip url" do
        expect(@fulfillment_request.packing_slip_url).to be_nil
      end
    end

    describe "with a custom packing slip provider" do
      before(:each) do
        Spree::ExternalFulfillment.packing_slip_provider_class = "PackingSlipProvider"
        job.perform(@fulfillment_request)
      end

      it "sets the packing slip url" do
        expect(@fulfillment_request.packing_slip_url).to eq("test_packing_slip_url")
      end
    end
  end

  describe "processing line items" do
    it "succeeds if the request is in the preparing state and has line items" do
      expect {
        job.process_line_items @fulfillment_request
      }.to_not raise_error
    end

    it "fails if the request is not in the preparing state" do
      @fulfillment_request.state = :waiting_for_preparation
      expect {
        job.process_line_items @fulfillment_request
      }.to raise_error(Spree::ExternalFulfillmentError)
    end

    it "fails with FulfillmentRequestAlreadyPreparedError if the request is waiting_for_fulfillment" do
      @fulfillment_request.state = :waiting_for_fulfillment
      expect {
        job.process_line_items @fulfillment_request
      }.to raise_error(Spree::FulfillmentRequestAlreadyPreparedError)
    end

    it "fails with FulfillmentRequestAlreadyPreparedError if the request is fulfilled" do
      @fulfillment_request.state = :fulfilled
      expect {
        job.process_line_items @fulfillment_request
      }.to raise_error(Spree::FulfillmentRequestAlreadyPreparedError)
    end

    it "fails with FulfillmentRequestAlreadyPreparedError if the request is preparation_failed" do
      @fulfillment_request.state = :preparation_failed
      expect {
        job.process_line_items @fulfillment_request
      }.to raise_error(Spree::FulfillmentRequestAlreadyPreparedError)
    end

    it "fails if the request does not have any associated line items" do
      expect {
        @fulfillment_request.order.line_items.each do |line_item|
          line_item.product.fulfillment_type = nil
          line_item.product.save!
        end
        job.process_line_items @fulfillment_request
      }.to raise_error(Spree::ExternalFulfillmentError)
    end
  end
end

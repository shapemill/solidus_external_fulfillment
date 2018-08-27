require 'spec_helper'

RSpec.describe Spree::LineItemFulfillmentInstruction, type: :model do
  before(:each) do
    @fulfillment_request = FactoryBot.create(:fulfillment_request)
    @valid_record = Spree::LineItemFulfillmentInstruction.create({
      fulfillment_request: @fulfillment_request,
      line_item: @fulfillment_request.order.line_items.first
    })
  end

  describe "Validation" do
    it "passes if all attributes are valid" do
      expect(@valid_record).to be_valid
    end

    it "fails if fulfillment_request is missing" do
      @valid_record.fulfillment_request = nil
      expect(@valid_record).to be_invalid
    end

    it "fails if line_item is missing" do
      @valid_record.line_item = nil
      expect(@valid_record).to be_invalid
    end
  end
end

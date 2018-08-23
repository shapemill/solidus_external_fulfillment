require 'spec_helper'

RSpec.describe Spree::Order, type: :model do
  describe "Completing an order" do
    describe "with one line item of fulfillment type x" do
      before(:each) do
        Spree::FulfillmentCenter.create({
          display_name: "Type 1 center",
          order_email: "a@b.c",
          fulfillment_type: :dummy_type_1
        })
        Spree::FulfillmentCenter.create({
          display_name: "Type 2 center",
          order_email: "a@b.c",
          fulfillment_type: :dummy_type_2
       })
        @fulfillment_type = "dummy_type_1"
        @order = FactoryBot.create(:order_ready_to_complete)
        product = @order.line_items.first.product
        product.fulfillment_type = @fulfillment_type
        product.save!

        @order.complete!
      end

      describe "creates one fulfillment request" do
        before(:each) do
          @fulfillment_request = Spree::FulfillmentRequest.first
        end

        it "and only one request" do
          expect(Spree::FulfillmentRequest.count).to equal(1)
        end

        it "associated with the order" do
          expect(@fulfillment_request.order.id).to equal(@order.id)
        end

        it "associated with a fulfillment center of the right type" do
          expect(@fulfillment_request.fulfillment_center.fulfillment_type).to eq(@fulfillment_type)
        end
      end
    end
  end
  describe "Completing an order with"
end

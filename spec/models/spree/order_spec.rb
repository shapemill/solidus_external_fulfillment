require 'spec_helper'

RSpec.describe Spree::Order, type: :model do
  describe "Completing an order with no fulfillment types" do
    it "creates no fulfillment requests" do
      @order = FactoryBot.create(:order_ready_to_complete)
      @order.complete!
      expect(@order.fulfillment_requests.count).to eq(0)
    end
  end

  describe "Completing an order with many fulfillment types" do
    before(:each) do
      @order = FactoryBot.create(:order_with_many_fulfillment_types)
      @order.complete!

      centers_by_id = {}
      @order.line_items.each do |line_item|
        fulfillment_center = line_item.assigned_fulfillment_center
        next if fulfillment_center.nil?
        centers_by_id[fulfillment_center.id] = fulfillment_center
      end
      @uniqe_fulfillment_centers = centers_by_id.values
    end

    it "creates a number of requests equaling the number of unique fulfullment centers" do
      expect(@uniqe_fulfillment_centers.length).to equal(@order.fulfillment_requests.count)
    end

    it "creates one request per fulfillment center" do
      center_ids = @uniqe_fulfillment_centers.map { |c| c.id }
      @order.fulfillment_requests.each do |request|
        center_id = request.fulfillment_center.id
        expect(center_ids.include?(center_id)).to eq(true)
        center_ids.delete(center_id)
      end
      expect(center_ids.length).to eq(0)
    end
  end

  describe "Shipping line items with no fulfillment types" do
    before(:each) do
      @tracking_number = "hello-tracking"
      @order = FactoryBot.create(:order_with_many_fulfillment_types_ready_to_ship)
      @order.ship_line_items_with_no_fulfillment_center(@tracking_number)
    end

    describe "creates one carton" do
      it "and only one carton" do
        expect(@order.cartons.count).to eq(1)
      end
      it "with the right tracking number" do
        expect(@order.cartons.first.tracking).to eq(@tracking_number)
      end
      it "with the right number of inventory units" do
        raise "understand this"
        # Add regular product with quantity > 1 to order. Should make this fail
        # expect(@order.cartons.first.inventory_units.count).to eq(@order.line_items_with_no_fulfillment_center.length)
      end
    end
  end
end

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
        fulfillment_center = @order.fulfillment_center_for_line_item(line_item)
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
end

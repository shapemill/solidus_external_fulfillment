require 'spec_helper'

RSpec.describe Spree::DefaultFulfillmentCenterAssigner do
  before(:each) do
    @type_1_default_center = Spree::FulfillmentCenter.create({
      display_name: "Default center for type 1",
      order_email: "a@b.c",
      fulfillment_type: :dummy_type_1
    })
    @type_1_secondary_center = Spree::FulfillmentCenter.create({
      display_name: "Secondary center for type 1",
      order_email: "a@b.c",
      fulfillment_type: :dummy_type_1
    })
    @type_2_default_center = Spree::FulfillmentCenter.create({
      display_name: "Default center for type 2",
      order_email: "a@b.c",
      fulfillment_type: :dummy_type_2
    })
    @type_2_secondary_center = Spree::FulfillmentCenter.create({
      display_name: "Secondary center for type 2",
      order_email: "a@b.c",
      fulfillment_type: :dummy_type_2
    })

    @order = FactoryBot.create(:order_ready_to_ship)
    @line_item = @order.line_items.first
  end

  it "assigns nil for line items belonging to product with no fulfillment type" do
    assigner = Spree::DefaultFulfillmentCenterAssigner.new(@line_item)
    expect(assigner.fulfillment_center).to be_nil
  end

  it "assigns a center matching the given product fulfillment type" do
    @line_item.product.fulfillment_type = :dummy_type_1
    assigner = Spree::DefaultFulfillmentCenterAssigner.new(@line_item)
    expect(assigner.fulfillment_center.fulfillment_type).to eq(@line_item.product.fulfillment_type)
  end

  it "assigns the default center for a given product fulfillment type" do
    @line_item.product.fulfillment_type = :dummy_type_1
    assigner = Spree::DefaultFulfillmentCenterAssigner.new(@line_item)
    expect(assigner.fulfillment_center.is_default_for_fulfillment_type).to be true
  end
end

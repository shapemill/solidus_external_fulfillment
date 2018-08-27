require 'spec_helper'

RSpec.describe Spree::Variant, type: :model do
  before(:each) do
    @variant = FactoryBot.create(:variant)
  end

  it "variant of product with no fulfillment type has tracks_inventory set to true" do
    expect(@variant.should_track_inventory?).to be(true)
  end

  it "variant of product with fulfillment type has tracks_inventory set to false" do
    @variant.product.fulfillment_type = :dummy_type_1
    @variant.product.save!
    expect(@variant.should_track_inventory?).to be(false)
  end
end

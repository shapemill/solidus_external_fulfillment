require 'spec_helper'

RSpec.describe Spree::FulfillmentCenter, type: :model do
  before(:each) do
    @valid_record = FactoryBot.create(:fulfillment_center)
  end

  describe "Validation" do
    it "passes if all attributes are valid" do
      expect(@valid_record).to be_valid
    end

    it "fails if order email is blank" do
      @valid_record.order_email = ""
      expect(@valid_record).to be_invalid
    end

    it "fails if display name is blank" do
      @valid_record.display_name = ""
      expect(@valid_record).to be_invalid
    end

    it "fails if fulfillment type is nil" do
      @valid_record.fulfillment_type = nil
      expect(@valid_record).to be_invalid
    end

    it "fails if default flag is nil" do
      @valid_record.is_default_for_fulfillment_type = nil
      expect(@valid_record).to be_invalid
    end
  end

  describe "Default flag" do
    it "is set on the first created item" do
      expect(@valid_record.is_default_for_fulfillment_type).to be true
    end

    it "is not set on the second created item" do
      record2 = FactoryBot.create(:fulfillment_center)
      expect(record2.is_default_for_fulfillment_type).to be false
    end

    it "is not set on the third created item" do
      FactoryBot.create(:fulfillment_center)
      record3 = FactoryBot.create(:fulfillment_center)
      expect(record3.is_default_for_fulfillment_type).to be false
    end

    it "gets unset on other records when set on a given record" do
      record2 = FactoryBot.create(:fulfillment_center)
      record2.is_default_for_fulfillment_type = true
      record2.save!
      @valid_record.reload
      expect(@valid_record.is_default_for_fulfillment_type).to be false
      expect(record2.is_default_for_fulfillment_type).to be true
    end

    it "cannot be false on all records of a given fulfillment type" do
      FactoryBot.create(:fulfillment_center)
      @valid_record.is_default_for_fulfillment_type = false
      @valid_record.save!
      @valid_record.reload
      expect(@valid_record.is_default_for_fulfillment_type).to be true
    end
  end
end

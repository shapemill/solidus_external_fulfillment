require 'spec_helper'

RSpec.describe Spree::FulfillmentRequest, type: :model do
  before(:each) do
    @valid_record = FactoryBot.create(:spree_fulfillment_request)
  end

  describe "Validation" do
    it "passes if all attributes are valid" do
      expect(@valid_record).to be_valid
    end

    it "fails if fulfillment center is missing" do
      @valid_record.fulfillment_center = nil
      expect(@valid_record).to be_invalid
    end

    it "fails if order is missing" do
      @valid_record.order = nil
      expect(@valid_record).to be_invalid
    end

    it "fails if state is nil" do
      @valid_record.state = nil
      expect(@valid_record).to be_invalid
    end

    it "fails if state is pending and there are no associated instructions"
  end

  describe "State transition" do
    describe "start_preparation" do
      it "succeeds if state is not_prepared" do
        expect {
          @valid_record.start_preparation!
        }.to_not raise_error
      end
      it "fails if state is preparing" do
        @valid_record.state = :preparing
        expect {
          @valid_record.start_preparation!
        }.to raise_error(StateMachines::InvalidTransition)
      end
      it "fails if state is pending" do
        @valid_record.state = :pending
        expect {
          @valid_record.start_preparation!
        }.to raise_error(StateMachines::InvalidTransition)
      end
      it "fails if state is fulfilled" do
        @valid_record.state = :fulfilled
        expect {
          @valid_record.start_preparation!
        }.to raise_error(StateMachines::InvalidTransition)
      end
      it "fails if state is preparation_failed" do
        @valid_record.state = :preparation_failed
        expect {
          @valid_record.start_preparation!
        }.to raise_error(StateMachines::InvalidTransition)
      end
    end

    describe "fail_preparation" do
      it "fails if state is not_prepared" do
        @valid_record.state = :not_prepared
        expect {
          @valid_record.fail_preparation!
        }.to raise_error(StateMachines::InvalidTransition)
      end
      it "succeeds if state is preparing" do
        @valid_record.state = :preparing
        expect {
          @valid_record.fail_preparation!
        }.to_not raise_error
      end
      it "fails if state is pending" do
        @valid_record.state = :pending
        expect {
          @valid_record.fail_preparation!
        }.to raise_error(StateMachines::InvalidTransition)
      end
      it "fails if state is fulfilled" do
        @valid_record.state = :fulfilled
        expect {
          @valid_record.fail_preparation!
        }.to raise_error(StateMachines::InvalidTransition)
      end
      it "fails if state is preparation_failed" do
        @valid_record.state = :preparation_failed
        expect {
          @valid_record.fail_preparation!
        }.to raise_error(StateMachines::InvalidTransition)
      end
    end

    describe "finish_preparation" do
      it "fails if state is not_prepared" do
        @valid_record.state = :not_prepared
        expect {
          @valid_record.finish_preparation!
        }.to raise_error(StateMachines::InvalidTransition)
      end
      it "succeeds if state is preparing" do
        @valid_record.state = :preparing
        expect {
          @valid_record.finish_preparation!
        }.to_not raise_error
      end
      it "fails if state is pending" do
        @valid_record.state = :pending
        expect {
          @valid_record.finish_preparation!
        }.to raise_error(StateMachines::InvalidTransition)
      end
      it "fails if state is fulfilled" do
        @valid_record.state = :fulfilled
        expect {
          @valid_record.finish_preparation!
        }.to raise_error(StateMachines::InvalidTransition)
      end
      it "fails if state is preparation_failed" do
        @valid_record.state = :preparation_failed
        expect {
          @valid_record.finish_preparation!
        }.to raise_error(StateMachines::InvalidTransition)
      end
    end

    describe "fulfill" do
      it "fails if state is not_prepared" do
        @valid_record.state = :not_prepared
        expect {
          @valid_record.fulfill!
        }.to raise_error(StateMachines::InvalidTransition)
      end
      it "fails if state is preparing" do
        @valid_record.state = :preparing
        expect {
          @valid_record.fulfill!
        }.to raise_error(StateMachines::InvalidTransition)
      end
      it "succeeds if state is pending" do
        @valid_record.state = :pending
        expect {
          @valid_record.fulfill!
        }.to_not raise_error
      end
      it "fails if state is fulfilled" do
        @valid_record.state = :fulfilled
        expect {
          @valid_record.fulfill!
        }.to raise_error(StateMachines::InvalidTransition)
      end
      it "fails if state is preparation_failed" do
        @valid_record.state = :preparation_failed
        expect {
          @valid_record.fulfill!
        }.to raise_error(StateMachines::InvalidTransition)
      end
    end

    describe "reset" do
      it "fails if state is not_prepared" do
        @valid_record.state = :not_prepared
        expect {
          @valid_record.reset!
        }.to raise_error(StateMachines::InvalidTransition)
      end
      it "fails if state is preparing" do
        @valid_record.state = :preparing
        expect {
          @valid_record.reset!
        }.to raise_error(StateMachines::InvalidTransition)
      end
      it "fails if state is pending" do
        @valid_record.state = :pending
        expect {
          @valid_record.reset!
        }.to_not raise_error
      end
      it "succeeds if state is fulfilled" do
        @valid_record.state = :fulfilled
        expect {
          @valid_record.reset!
        }.to_not raise_error
      end
      it "succeeds if state is preparation_failed" do
        @valid_record.state = :preparation_failed
        expect {
          @valid_record.reset!
        }.to_not raise_error
      end
    end
  end
end

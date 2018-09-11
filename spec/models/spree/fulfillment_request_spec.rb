require 'spec_helper'

RSpec.describe Spree::FulfillmentRequest, type: :model do
  before(:each) do
    @valid_record = FactoryBot.create(:fulfillment_request)
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

    it "fails if state is waiting_for_fulfillment and there are no associated instructions"
  end

  describe "Fulfilling" do
    before(:each) do
      @order = FactoryBot.create(:order_with_many_fulfillment_types_ready_to_ship)
    end

    describe "a single request of an order" do
      before(:each) do
        @order = FactoryBot.create(:order_with_many_fulfillment_types_ready_to_ship)
        @fulfillment_request = @order.fulfillment_requests.first
        @fulfillment_request.start_preparation!
        @fulfillment_request.finish_preparation!
        @tracking_number = "test-tracking-number"
        @fulfillment_request.fulfill_with_tracking_number(@tracking_number)
        @fulfillment_request.reload
      end

      it "creates one carton with the right tracking number" do
        expect(@order.cartons.count).to eq(1)
        expect(@order.cartons.first.tracking).to eq(@tracking_number)
      end

      it "creates a carton referencing the request" do
        carton_count = Spree::Carton.where(fulfillment_request: @fulfillment_request).count
        expect(carton_count).to eq(1)
      end

      it "marks the request as fulfilled" do
        expect(@fulfillment_request.state).to eq("fulfilled")
      end
    end

    describe "all requests of an order" do
      before(:each) do
        @order.fulfillment_requests.each do |fulfillment_request|
          fulfillment_request.start_preparation!
          fulfillment_request.finish_preparation!
          tracking_number = "test-tracking-number-#{fulfillment_request.id}"
          fulfillment_request.fulfill_with_tracking_number(tracking_number)
        end
      end

      it "creates one carton per request with the right tracking number" do
        expect(@order.cartons.count).to eq(@order.fulfillment_requests.count)
        @order.cartons.each_with_index do |carton, index|
          fulfillment_request = @order.fulfillment_requests[index]
          tracking_number = "test-tracking-number-#{fulfillment_request.id}"
          expect(carton.tracking).to eq(tracking_number)
        end
      end

      it "creates one carton referencing each request" do
        @order.cartons.each_with_index do |_, index|
          fulfillment_request = @order.fulfillment_requests[index]
          carton_count = Spree::Carton.where(fulfillment_request: fulfillment_request).count
          expect(carton_count).to eq(1)
        end
      end
    end
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
      it "fails if state is waiting_for_fulfillment" do
        @valid_record.state = :waiting_for_fulfillment
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
      it "fails if state is waiting_for_fulfillment" do
        @valid_record.state = :waiting_for_fulfillment
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
      it "fails if state is waiting_for_fulfillment" do
        @valid_record.state = :waiting_for_fulfillment
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
      it "succeeds if state is waiting_for_fulfillment" do
        @valid_record.state = :waiting_for_fulfillment
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
      it "fails if state is waiting_for_fulfillment" do
        @valid_record.state = :waiting_for_fulfillment
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

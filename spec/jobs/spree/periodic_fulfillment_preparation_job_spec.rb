require 'spec_helper'

RSpec.describe Spree::PeriodicFulfillmentPreparationJob, type: :job do
  subject(:job) { Spree::PeriodicFulfillmentPreparationJob.new }

  before(:each) do
    @order = FactoryBot.create(:order_with_many_fulfillment_types_ready_to_ship)
  end

  describe "Invocation record" do
    it "is created if no running records exist" do
      expect(job.create_invocation_record).to_not eq(nil)
    end
    it "is not created if running record(s) exist" do
      FactoryBot.create(:periodic_fulfillment_preparation_job_invocation)
      expect(job.create_invocation_record).to eq(nil)
    end
  end

  describe "Performing job" do
    describe "if running invocation records exist" do
      before(:each) do
        @other_invocation = FactoryBot.create(:periodic_fulfillment_preparation_job_invocation)
      end
      it "raises PeriodicFulfillmentPreparationInProgressError" do
        expect {
          job.perform
        }.to raise_error(Spree::PeriodicFulfillmentPreparationInProgressError)
      end
      it "does not create an invocation record" do
        expect(Spree::PeriodicFulfillmentPreparationJobInvocation.count).to eq(1)
        expect {
          job.perform
        }.to raise_error(Spree::PeriodicFulfillmentPreparationInProgressError)
        expect(Spree::PeriodicFulfillmentPreparationJobInvocation.count).to eq(1)
      end
    end

    describe "if there are no running invocation records" do
      it "creates one 'finished' invocation record" do
        expect(Spree::PeriodicFulfillmentPreparationJobInvocation.count).to eq(0)
        job.perform
        expect(Spree::PeriodicFulfillmentPreparationJobInvocation.finished.count).to eq(1)
      end
      it "creates an invocation record with a running time" do
        job.perform
        expect(Spree::PeriodicFulfillmentPreparationJobInvocation.finished.count).to eq(1)
        record = Spree::PeriodicFulfillmentPreparationJobInvocation.first
        expect(record.running_time).to_not eq(nil)
      end
    end
  end
end

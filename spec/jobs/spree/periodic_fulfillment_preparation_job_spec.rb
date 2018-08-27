require 'spec_helper'

RSpec.describe Spree::PeriodicFulfillmentPreparationJob, type: :job do
  subject(:job) { Spree::PeriodicFulfillmentPreparationJob.new }

  before(:each) do
    @order = FactoryBot.create(:order_with_many_fulfillment_types_ready_to_ship)
  end

  describe "Invocation record" do
    it "is created if no running records exist" do
      expect(job.invocation_record).to_not eq(nil)
    end
    it "is not created if running record(s) exist" do
      FactoryBot.create(:periodic_fulfillment_preparation_job_invocation)
      expect(job.invocation_record).to eq(nil)
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
        job.perform
        expect(Spree::PeriodicFulfillmentPreparationInvocation.count).to eq(0)
      end
    end

    describe "if there are no running invocation records" do
      it "creates one 'finished' invocation record"
      it "creates an invocation record with a running time"
    end
  end
end

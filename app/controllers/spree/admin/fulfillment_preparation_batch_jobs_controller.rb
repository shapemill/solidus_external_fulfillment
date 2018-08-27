class Spree::Admin::FulfillmentPreparationBatchJobsController < Spree::Admin::BaseController
  def start_new
    Spree::FulfillmentPreparationBatchJob.perform_later
    flash[:notice] = 'Job started'
    redirect_to admin_fulfillment_preparation_batch_jobs_url
  end

  def index
    @invocations = Spree::FulfillmentPreparationBatchJobInvocation.all.order(created_at: :desc).limit(100)
  end
end

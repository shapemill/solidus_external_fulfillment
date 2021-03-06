module Spree
  class FulfillmentPreparationBatchJob < ApplicationJob
    def perform(*_args)
      # Create an invocation record describing the progress of this job
      invocation = create_invocation_record
      if invocation.nil?
        raise FulfillmentPreparationBatchInProgressError.new(
          "Periodic fulfillment preparation job already in progress"
        )
      end

      # If we made it here, there are no other jobs running in parallel.

      # Reset any requests that previously failed preparation
      Spree::FulfillmentRequest.where(state: :preparation_failed).find_each(batch_size: 10) do |request|
        request.reset!
        invocation.reset_count += 1
      end
      invocation.save!

      # Gather requests by fulfillment center id
      requests_by_fulfillment_center_id = {}
      Spree::FulfillmentRequest.where(state: :waiting_for_preparation).find_each(batch_size: 10) do |request|
        center_id = request.fulfillment_center.id
        requests = requests_by_fulfillment_center_id[center_id] || []
        requests << request
        requests_by_fulfillment_center_id[center_id] = requests
      end

      # For each fulfillment center, use customizable hook
      # to select requests for preparation and prepare those
      # requests
      requests_by_fulfillment_center_id.each do |fulfillment_center_id, requests|
        fulfillment_center = Spree::FulfillmentCenter.find fulfillment_center_id
        next if !fulfillment_checker(fulfillment_center, requests).should_prepare_fulfillment

        requests.each do |request|
          preparation_job = Spree::FulfillmentRequestPreparationJob.new
          request.start_preparation!
          preparation_job.perform(request)
          invocation.prepared_count += 1 if request.waiting_for_fulfillment?
          invocation.failed_count += 1 if request.preparation_failed?
          invocation.save!

          fulfillment_center.latest_batch_fulfillment_job_at = DateTime.now
          fulfillment_center.save!
        end
      end

      # let the notifier know we're done
      notifier.finished(invocation)

      # Mark the invocation record as finished
      invocation.state = :finished
      invocation.running_time = DateTime.now.to_f - invocation.created_at.to_f
      invocation.save!
    rescue FulfillmentPreparationBatchInProgressError
      # Another job is already in progress. Let the world know
      raise
    rescue StandardError => e
      # let the notifier know what went wrong
      notifier.failed(e)

      # Mark the invocation record as failed
      invocation.state = :failed
      invocation.error_message = e.message
      invocation.save!
    end

    def notifier
      notifier_class_name = Spree::ExternalFulfillment.batch_fulfillment_notifier_class
      notifier_class_name.constantize.new
    end

    def fulfillment_checker(fulfillment_center, fulfillment_requests)
      checker_class_name = Spree::ExternalFulfillment.batch_fulfillment_checker_class
      checker_class_name.constantize.new(fulfillment_center, fulfillment_requests)
    end

    def create_invocation_record
      invocation = nil
      ActiveRecord::Base.transaction do
        if ActiveRecord::Base.connection.adapter_name.downcase.include?('postgres')
          # If running on postgres, lock the invocations table before
          # preforming the check. The lock is automatically released at the end
          # of the containing transaction
          table_name = Spree::FulfillmentPreparationBatchJobInvocation.table_name
          ActiveRecord::Base.connection.execute("LOCK #{table_name} IN ACCESS EXCLUSIVE MODE")
        end

        if Spree::FulfillmentPreparationBatchJobInvocation.running.empty?
          # No jobs are running
          # Create an invocation record for keeping track of the progress of this job
          invocation = Spree::FulfillmentPreparationBatchJobInvocation.create

          # Reset counters
          invocation.failed_count = 0
          invocation.reset_count = 0
          invocation.prepared_count = 0
        end
      end
      invocation
    end
  end
end

module Spree
  class PeriodicFulfillmentPreparationJob < ApplicationJob
    queue_as :default

    def perform(*_args)
      # Create an invocation record describing the progress of this job
      invocation = create_invocation_record
      if invocation.nil?
        raise PeriodicFulfillmentPreparationInProgressError.new(
          "Periodic fulfillment preparation job already in progress"
        )
      end

      # If we made it here, there are no other jobs running in parallel.
      # Start gathering requests to prepare
      requests_to_prepare = []

      # Reset any requests that previously failed preparation
      Spree::FulfillmentRequest.where(state: :preparation_failed).find_each(batch_size: 10) do |request|
        request.reset!
        invocation.reset_count += 1
      end
      invocation.save!

      # Gather requests by fulfillment center id
      requests_by_fulfillment_center_id = {}
      Spree::FulfillmentRequest.where(state: :not_started).all do |request|
        center_id = request.fulfillment_center.id
        request.start_preparation!
        requests = requests_by_fulfillment_center_id[center_id] || []
        requests << request
        requests_by_fulfillment_center_id[center_id] = requests
      end

      # For each fulfillment center, use customizable hook
      # to see if requests should be prepared
      requests_by_fulfillment_center_id.each do |fulfillment_center_id, requests|
        fulfillment_center = Spree::FulfillmentCenter.find fulfillment_center_id
        next if !fulfillment_checker(fulfillment_center, requests).should_prepare_fulfillment

        requests.each do |request|
          requests_to_prepare << request
        end
      end

      # Prepare the requests
      requests_to_prepare.each do |request|
        preparation_job = Spree::FulfillmentRequestPreparationJob.new
        preparation_job.perform(request)
        invocation.prepared_count += 1 if preparation_job.waiting_for_fulfillment?
        invocation.failed_count += 1 if preparation_job.preparation_failed?
        invocation.save!
      end

      # let the notifier know we're done
      notifier.finished(
        prepared_count: invocation.prepared_count,
        failed_count: invocation.failed_count,
        reset_count: invocation.reset_count,
        duration_s: invocation.running_time
      )

      # Mark the invocation record as finished
      invocation.state = :finished
      invocation.running_time = DateTime.now.to_f - invocation.created_at.to_f
      invocation.save!
    rescue PeriodicFulfillmentPreparationInProgressError => e
      # Another job is already in progress. Nothing further
    rescue StandardError => e
      # let the notifier know what went wrong
      notifier.failed(e)

      # Mark the invocation record as failed
      invocation.state = :failed
      invocation.error_message = e.message
      invocation.save!
    end

    def notifier
      notifier_class_name = Spree::ExternalFulfillment.periodic_fulfillment_notifier_class
      notifier_class_name.constantize.new
    end

    def fulfillment_checker(fulfillment_center, fulfillment_requests)
      checker_class_name = Spree::ExternalFulfillment.periodic_fulfillment_checker_class
      checker_class_name.constantize.new(fulfillment_center, fulfillment_requests)
    end

    def create_invocation_record
      ActiveRecord::Base.transaction do
        if ActiveRecord::Base.connection.instance_of? ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
          # If running on postgres, lock the invocations table for writing before
          # preforming the check. The lock is automatically released at the end
          # of the containing transaction
          ActiveRecord::Base.connection.execute('LOCK table_name IN ACCESS EXCLUSIVE MODE')
        end

        if Spree::PeriodicFulfillmentPreparationJobInvocation.running.count == 0
          # No jobs are running
          # Create an invocation record for keeping track of the progress of this job
          invocation = Spree::PeriodicFulfillmentPreparationJobInvocation.create
        end
      end
      invocation
    end
  end
end

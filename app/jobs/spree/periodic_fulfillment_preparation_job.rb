module Spree
  class PeriodicFulfillmentPreparationJob < ApplicationJob
    queue_as :default

    def perform(*_args)
      # TODO: some kind of locking here? To ensure only one job of this kind is run at a time

      # Reset any requests that previously failed preparation
      reset_count = 0
      Spree::FulfillmentRequest.where(state: :preparation_failed).find_each(batch_size: 10) do |request|
        request.reset!
        reset_count += 1
      end

      # Gather requests by fulfillment center id
      requests_by_fulfillment_center_id = {}
      Spree::FulfillmentRequest.where(state: :not_started).find_each(batch_size: 10) do |request|
        center_id = request.fulfillment_center.id
        requests = requests_by_fulfillment_center_id[center_id] || []
        requests << request
        requests_by_fulfillment_center_id[center_id] = requests
      end

      # Intitialize counters
      failed_count = 0
      prepared_count = 0
      start_time = Time.now

      # Prepare requests for each fulfillment center
      requests_by_fulfillment_center_id.each do |fulfillment_center_id, requests|
        fulfillment_center = Spree::FulfillmentCenter.find fulfillment_center_id
        next if !fulfillment_checker(fulfillment_center, requests).should_prepare_fulfillment

        requests.each do |request|
          preparation_job = Spree::FulfillmentRequestPreparationJob.new
          preparation_job.perform(request)
          prepared_count += 1 if preparation_job.waiting_for_fulfillment?
          failed_count += 1 if preparation_job.preparation_failed?
        end
      end

      # let the notifier know we're done
      duration_s = (Time.now - start_time).to_f
      notifier.finished(
        prepared_count: prepared_count,
        failed_count: failed_count,
        reset_count: reset_count,
        duration_s: duration_s
      )
    rescue StandardError => e
      # let the notifier know what went wrong
      notifier.failed(e)
    end

    def notifier
      notifier_class_name = Spree::ExternalFulfillment.periodic_fulfillment_notifier_class
      notifier_class_name.constantize.new
    end

    def fulfillment_checker(fulfillment_center, fulfillment_requests)
      checker_class_name = Spree::ExternalFulfillment.periodic_fulfillment_checker_class
      checker_class_name.constantize.new(fulfillment_center, fulfillment_requests)
    end
  end
end

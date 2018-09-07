module Spree
  class ApplicationJob < ActiveJob::Base
    # Automatically retry jobs that encountered a deadlock
    # retry_on ActiveRecord::Deadlocked

    # Most jobs are safe to ignore if the underlying records are no longer available
    # discard_on ActiveJob::DeserializationError

    queue_as Spree::ExternalFulfillment.queue_jobs_as
  end
end

module Spree
  class DefaultPeriodicFulfillmentNotifier
    def finished(prepared_count:, failed_count:, reset_count:, duration_s:)
      puts prepared_count
      puts failed_count
      puts reset_count
      puts duration_s
    end

    def failed(error)
      puts error
    end
  end
end

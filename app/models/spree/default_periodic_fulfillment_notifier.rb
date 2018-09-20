module Spree
  class DefaultPeriodicFulfillmentNotifier
    def finished(invocation)
    end

    def failed(error)
      # puts error
    end
  end
end

module Spree
  class PeriodicFulfillmentPreparationJobInvocation < ApplicationRecord
    enum state: [
      :running,
      :finished,
      :failed
    ]
  end
end

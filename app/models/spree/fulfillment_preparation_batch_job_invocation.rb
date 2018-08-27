module Spree
  class FulfillmentPreparationBatchJobInvocation < ApplicationRecord
    enum state: [
      :running,
      :finished,
      :failed
    ]
  end
end

class Spree::DefaultPeriodicFulfillmentNotifierClass
  def initialize
  end

  def finished(:prepared_count, :failed_count, :reset_count, :duration_s)
  end

  def failed(error)
  end
end

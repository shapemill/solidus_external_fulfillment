class Spree::DefaultPeriodicFulfillmentChecker
  def initialize(fulfillment_center, fulfillment_requests)
    @fulfillment_center = fulfillment_center
    @fulfillment_requests = fulfillment_requests
  end

  def should_prepare_fulfillment
    cost_threshold_reached = true
    cost_threshold = @fulfillment_center.periodic_fulfillment_cost_threshold
    if cost_threshold > 0
      total_cost_price = 0
      @fulfillment_requests.each do |fulfillment_request|
        fulfillment_request.line_items.each do |line_item|
          total_cost_price += line_item.cost_price
        end
      end
      cost_threshold_reached = total_cost_price > cost_threshold
    end

    time_threshold_reached = true
    time_threshold = fulfillment_center.periodic_fulfillment_cost_threshold
    if time_threshold > 0
      if @fulfillment_center.latest_periodic_fulfillment_at.nil?
        time_threshold_reached = true
      else
        time_since_latest_job = DateTime.now.to_f - @fulfillment_center.latest_periodic_fulfillment_job_at.to_f
        time_threshold_reached = time_since_latest_job > time_threshold
      end
    end

    cost_threshold_reached && time_threshold_reached
  end
end

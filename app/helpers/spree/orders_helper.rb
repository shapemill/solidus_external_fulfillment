module Spree::OrdersHelper
  def fulfillment_request_pill_class(fulfillment_request)
    if fulfillment_request.waiting_for_fulfillment?
      "pill-pending"
    elsif fulfillment_request.preparing?
      "pill-pending"
    elsif fulfillment_request.fulfilled?
      "pill-active"
    elsif fulfillment_request.preparation_failed?
      "pill-error"
    end
  end

  def fulfillment_request_prepare_button(fulfillment_request)
    link_to_with_icon(
      "play",
      nil,
      admin_fulfillment_request_start_preparation_url(fulfillment_request.id),
      method: :put,
      data: { confirm: "Start preparing fulfillment?" }
    )
  end

  def fulfillment_request_reset_button(fulfillment_request)
    link_to_with_icon(
      "undo",
      nil,
      admin_fulfillment_request_reset_url(fulfillment_request.id),
      method: :put,
      data: { confirm: "Reset this fulfillment request?" }
    )
  end

  def fulfillment_request_show_button(fulfillment_request)
    link_to_with_icon(
      "external-link",
      nil,
      external_fulfillment_request_url(fulfillment_request.hash_id),
      target: :_blank
    )
  end

  def fulfillment_request_resend_button(fulfillment_request)
    email = fulfillment_request.fulfillment_center.order_email
    link_to_with_icon(
      "envelope",
      nil,
      admin_fulfillment_request_resend_url(fulfillment_request.id),
      method: :post,
      data: {
        confirm: "Resend fulfillment instructions to email address '#{email}'?"
      }
    )
  end
end

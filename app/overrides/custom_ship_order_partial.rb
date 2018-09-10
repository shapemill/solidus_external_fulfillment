Deface::Override.new(
  virtual_path: "spree/admin/orders/_shipment",
  name: "custom_ship_order_partial",
  replace: "erb[loud]:contains('form_tag(\"#\", class: \"admin-ship-shipment\")')",
  closing_selector: "erb[silent]:contains('end')",
  original: 'd2ed1e8dd29f38e592c0ad682f8554e7d8ea4ca8',
  disabled: false) do
    <<-HTML
    <%= render partial: 'fulfillment', locals: { order: @order } %>
    HTML
end

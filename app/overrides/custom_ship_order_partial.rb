Deface::Override.new(:virtual_path => "spree/admin/orders/_shipment",
  :name => "custom_ship_order_partial",
  :replace => "erb[loud]:contains('form_tag(\"#\", class: \"admin-ship-shipment\")')",
  :closing_selector => "erb[silent]:contains('end')",
  :disabled => false) do
    <<-HTML
    <%= render partial: 'fulfillment', locals: { order: @order } %>
    HTML
  end





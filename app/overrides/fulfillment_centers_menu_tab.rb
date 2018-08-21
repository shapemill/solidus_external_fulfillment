Deface::Override.new(
  virtual_path: "spree/admin/shared/_menu",
  name: "fulfillment_centers_admin_tab",
  insert_bottom: "[data-hook='admin_tabs']",
  original: 'b7b242ee058673679949d7e3050be5974938294d',
  disabled: false) do
    <<-HTML
    <% if can? :admin, Spree::FulfillmentCenter %>
      <%= tab(:fulfillment_centers, icon: 'gift') %>
    <% end %>
    HTML
end

Deface::Override.new(
  virtual_path: "spree/admin/shared/_menu",
  name: "fulfillment_centers_admin_tab",
  insert_bottom: "[data-hook='admin_tabs']",
  disabled: false) do
    <<-HTML
    <% if can? :admin, Spree::FulfillmentCenter %>
      <%= tab(:fulfillment_centers, icon: 'gift') %>
    <% end %>
    HTML
end

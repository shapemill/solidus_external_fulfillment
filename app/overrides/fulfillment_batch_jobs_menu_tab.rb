Deface::Override.new(
  virtual_path: "spree/admin/shared/_menu",
  name: "fulfillment_batch_jobs_menu_tab",
  insert_bottom: "[data-hook='admin_tabs']",
  original: 'b7b242ee058673679949d7e3050be5974938294d',
  disabled: false) do
    <<-HTML
      <% if can? :admin, nil %>
        <%= tab(:fulfillment_preparation_batch_jobs, url: admin_fulfillment_preparation_batch_jobs_url, icon: 'list') %>
      <% end %>
    HTML
end

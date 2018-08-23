Deface::Override.new(
  virtual_path: "spree/admin/products/_form",
  name: "fulfillment_types_in_product_form",
  insert_before: "[data-hook='admin_product_form_taxons']",
  original: '506b56eca006c18cb7ebc7036682dac21d31a542',
  text: '
  <div data-hook="admin_product_form_fulfillment_type">
    <%= f.field_container :fulfillment_type do %>
      <%= f.label :fulfillment_type %>
      <%= f.select(
        :fulfillment_type,
        Spree::Product.fulfillment_types.keys.map { |w| [w.humanize, w] },
        { include_blank: true },
        { class: "custom-select"}
      )%>
    <% end %>
  </div>
  ',
  disabled: false
)

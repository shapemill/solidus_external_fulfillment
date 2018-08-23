Deface::Override.new(
  virtual_path: "spree/admin/products/index",
  name: "product_list_fulfillment_type_header",
  insert_before: "[data-hook='admin_products_index_header_actions']",
  text: '<th class="align-right">Fulfillment type</td>',
  original: '1cf1e743e552f1fae35c0f3584123a8e3058e27d',
  disabled: false
)

Deface::Override.new(
  virtual_path: "spree/admin/products/index",
  name: "product_list_fulfillment_columns",
  insert_before: "[data-hook='admin_products_index_row_actions']",
  text: '<td class="align-right"><%= product.fulfillment_type.nil? ? "None" : product.fulfillment_type.humanize %></td>',
  original: '5649fa165c0a2dd5108d3b7a4b733e3371b35b39',
  disabled: false
)

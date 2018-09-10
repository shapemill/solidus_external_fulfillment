Deface::Override.new(
  virtual_path: "spree/admin/orders/_shipment_manifest",
  name: "fulfillment_center_in_shipment_line_items",
  insert_bottom: "td.item-name",
  disabled: false,
  text: '<br><strong>Assigned FC:</strong> <%= item.line_item.assigned_fulfillment_center.nil? ? "None" : item.line_item.assigned_fulfillment_center.display_name %>'
)

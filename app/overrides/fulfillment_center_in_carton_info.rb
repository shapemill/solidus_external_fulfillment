Deface::Override.new(
  virtual_path: "spree/admin/orders/_carton",
  name: "fulfillment_center_in_carton",
  insert_before: "tr.shipment-numbers",
  original: '2ed9d6e0e60f3c8ed85c73d53847e221fb85aa0a',
  disabled: false,
  text: '<% if !carton.fulfillment_request.nil? %>
  <tr class="fulfillment-center">
    <td colspan="5">
      <strong><%= t("spree.fulfillment_center") %>:&nbsp;</strong><%= carton.fulfillment_request.fulfillment_center.name %>
    </td>
  </tr>
<% end %>'

)



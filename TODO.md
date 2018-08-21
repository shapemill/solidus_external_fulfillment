# `solidus_external_fulfillment`

## Models

* FulfillmentCenter
* FulfillmentRequest__
  * `address_tag_url` ⚠️
  * `packing_slip_url` ⚠️ 
* LineItemFulfillmentInstruction

## Decorations
* Spree::Store
 * `latest_periodic_fulfillment_check_at` ⚠️
* Spree::Order
 * override finalize! to create empty fulfillment requests, one per unique fulfillment center ⚠️

## Jobs
* Prepare fulfillment request
* Periodic fulfillment + `PeriodicFulfillmentJobChecker`

## Routes

* get ship/[id]
* put ship/[id]
* resource fulfillment_centers

## Views

* Custom ship template
* Fulfillment centers admin tab
* Overrides
  * Add fulfillment type in product list
  * Add fulfillment type in product edit

## Mailers

* FulfillmentRequestMailer
* PeriodicFulfillmentCheckMailer

## Misc
* Hook for getting fulfillment instruction table columns (as overridable partial?)
* Hook for fulfillment instructions box partial
* Disable track inventory for products with a fulfillment_type

## Config
* `FulfillmentRequestPreparer` prepare `fulfillment_request`, `line_items`
* `PackingSlipRenderer` render `fulfillment_request` -> data
* `AddressTagRenderer` render `fulfillment_request` -> data
* periodic fulfillment params
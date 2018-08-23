# `solidus_external_fulfillment`

## Models

* FulfillmentCenter
* FulfillmentRequest__
  * `packing_slip_url` ⚠️
* LineItemFulfillmentInstruction

## Decorations
* Spree::Store
 * `latest_periodic_fulfillment_check_at` ⚠️

## Jobs
* Prepare fulfillment request
* Periodic fulfillment + `PeriodicFulfillmentJobChecker`

## Routes

* ship items from fulfillment request
* ship manual items from order

## Views

* Overrides
  * Add fulfillment type in product list
  * Add fulfillment type in product edit

## Mailers

* FulfillmentRequestMailer
* PeriodicFulfillmentCheckMailer

## Misc
* Disable track inventory for products with a fulfillment_type

## Config
* periodic fulfillment params


## Factories

### Order
 * ready to be completed
 * having 5 line items, 4 of which reference unique fulfillment centers
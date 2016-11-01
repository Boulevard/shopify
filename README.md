# Shopify

[![Build Status](https://semaphoreci.com/api/v1/boulevard/shopify/branches/master/badge.svg)](https://semaphoreci.com/boulevard/shopify)

An Elixir client for the Shopify API.  Currently under development.

Todo:
 * More resources
 * More tests

### Resources

| Resource |  Implemented? |
|----------|:-------------:|
| Abandoned checkouts |   |
| ApplicationCharge |   |
| Article |   |
| Asset |   |
| Blog |   |
| CarrierService |   |
| Collect |   |
| Comment |   |
| Country |   |
| CustomCollection |   |
| Customer | ✓ |
| CustomerAddress |   |
| CustomerSavedSearch |   |
| Discount |   |
| Event |   |
| Fulfillment |   |
| FulfillmentEvent |   |
| FulfillmentService |   |
| Gift Card |   |
| Location |   |
| Metafield |   |
| Multipass |   |
| Order | ✓ |
| Order Risks |   |
| Page |   |
| Policy |   |
| Product | ✓ |
| Product Image |   |
| Product Variant | ✓ |
| Province |   |
| RecurringApplicationCharge |   |
| Redirect |   |
| Refund |   |
| ScriptTag |   |
| Shipping Zone |   |
| Shop | ✓ |
| SmartCollection |   |
| Theme |   |
| Transaction |   |
| User |   |
| Webhook | ✓ |


## Installation

  1. Add shopify to your list of dependencies in `mix.exs`:

        def deps do
          [{:shopify, github: "Boulevard/shopify"}]
        end

  2. Ensure shopify is started before your application:

        def application do
          [applications: [:shopify]]
        end

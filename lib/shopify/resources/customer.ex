defmodule Shopify.Customer do
  use Shopify.Resource,
    import: [:find, :update]

  @singular "customer"
  @plural "customers"
end

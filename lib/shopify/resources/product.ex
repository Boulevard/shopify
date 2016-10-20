defmodule Shopify.Product do
  use Shopify.Resource,
    import: [:find, :update]

  @singular "product"
  @plural "products"
end

defmodule Shopify.Shop do
  use Shopify.Resource,
    singleton: true,
    import: [:find]

  @singular "shop"
  @plural "shops"
end

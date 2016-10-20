defmodule Shopify.Variant do
  use Shopify.Resource,
    import: [:find, :update]

  @singular "variant"
  @plural "variants"
end

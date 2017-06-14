defmodule Shopify.Order do
  use Shopify.Resource, import: [:create]

  alias Shopify.Request

  @singular "order"
  @plural "orders"

  def cancel(session, id, params) do
    result = Request.post(session, "/#{@plural}/#{id}/cancel.json", params)

    with {:ok, %{"order" => order}} <- result,
      do: {:ok, order}
  end
end

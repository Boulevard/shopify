defmodule Shopify.Webhook do
  use Shopify.Resource,
    import: [:find, :update, :create, :delete]

  @singular "webhook"
  @plural "webhooks"

  alias Shopify.Config

  def authenticate_callback(hmac, body) do
    case digest = compute_digest(body) do
      ^hmac -> {:ok, digest}
      _ -> {:error, digest}
    end
  end

  def compute_digest(data) do
    :crypto.hmac(:sha256, Config.get(:secret), data)
    |> Base.encode64
    |> String.trim
  end
end

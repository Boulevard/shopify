defmodule Shopify.Webhook do
  use Shopify.Resource,
    import: [:find, :update, :create, :delete]

  @singular "webhook"
  @plural "webhooks"

  def authenticate_callback(hmac, body) do
    case digest = compute_digest(body) do
      ^hmac -> {:ok, digest}
      _ -> {:error, digest}
    end
  end

  def compute_digest(data) do
    secret = Application.get_env(:shopify, :secret)
    :crypto.hmac(:sha256, secret, data)
    |> Base.encode64
    |> String.strip
  end
end

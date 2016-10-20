defmodule Shopify.Oauth do
  use OAuth2.Strategy
  alias OAuth2.Strategy.AuthCode

  # Public API
  def create(shopid, options \\ []) do
    secrets = Application.get_all_env(:shopify)
    oauth_base = secrets[:oauth_site] || "https://#{shopid}.myshopify.com/admin"

    OAuth2.Client.new([
      strategy: __MODULE__,
      client_id: secrets[:api_key],
      client_secret: secrets[:secret],
      redirect_uri: options[:redirect_uri],
      site: oauth_base,
      authorize_url: "#{oauth_base}/oauth/authorize",
      token_url: "#{oauth_base}/oauth/access_token"
    ])
  end

  def authorize_url!(shopid, params \\ []) do
    shopid
      |> create()
      |> OAuth2.Client.put_param(:scope, "read_products,write_products")
      |> OAuth2.Client.authorize_url!(params)
  end

  def get_token!(shopid, options \\ []) do
    OAuth2.Client.get_token!(create(shopid, options), options)
  end

  # Strategy Callbacks
  def authorize_url(client, params) do
    AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_header("Accept", "application/json")
    |> AuthCode.get_token(params, headers)
  end
end

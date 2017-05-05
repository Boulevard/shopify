defmodule Shopify.Oauth do
  use OAuth2.Strategy
  alias OAuth2.Strategy.AuthCode

  alias Shopify.Config

  # Public API
  def create(shopid, options \\ []) do
    oauth_base = Config.get(:oauth_site) || "https://#{shopid}.myshopify.com/admin"

    client = OAuth2.Client.new([
      strategy: __MODULE__,
      client_id: Config.get(:api_key),
      client_secret: Config.get(:secret),
      redirect_uri: Config.get(:redirect_uri),
      site: oauth_base,
      authorize_url: "#{oauth_base}/oauth/authorize",
      token_url: "#{oauth_base}/oauth/access_token",
    ])

    if options[:token] do
      client
      |> Map.put(:token, %OAuth2.AccessToken{token_type: "Bearer", access_token: options[:token]})
    else
      client
    end
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

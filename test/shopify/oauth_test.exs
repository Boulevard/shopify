defmodule Shopify.OauthTest do
  use ExUnit.Case
  alias Shopify.Oauth

  setup do
    bypass = Bypass.open
    Application.put_env(:shopify, :oauth_site, endpoint_url(bypass.port))
    {:ok, bypass: bypass}
  end

  test "create/2 sets the OAuth strategy" do
    shopid = "spatula-city"
    %OAuth2.Client{strategy: strategy} = Oauth.create(shopid)

    assert strategy == Shopify.Oauth
  end

  test "authorize_url!/2 returns a URL", %{bypass: bypass} do
    shopid = "spatula-city"
    scopes = "read_widgets"
    redirect_uri = "https://foobar.baz"
    options = %{shopid: shopid, scope: scopes, redirect_uri: redirect_uri}
    auth_url = Shopify.Oauth.authorize_url!(shopid, options)
    expected_params = %{
      client_id: nil,
      redirect_uri: redirect_uri,
      response_type: "code",
      scope: scopes,
      shopid: shopid
    }
    assert auth_url == ("#{endpoint_url(bypass.port)}/oauth/authorize?" <> URI.encode_query(expected_params))
  end

  # NOTE: as of oauth2 0.7.0, this function will return
  # an OAuth2.Client struct with a token member.
  # Be Ready!
  test "get_token/2 returns an AccessToken", %{bypass: bypass} do
    shopid = "spatula-city"
    faux_token = "abcd1234"
    token_map = %{access_token: faux_token}
    token_json_string = Poison.Encoder.encode(token_map, []) |> to_string
    options = [code: "wxyz9876"]
    Bypass.expect bypass, fn conn ->
      assert "/oauth/access_token" == conn.request_path
      assert "POST" == conn.method
      conn
      |> Plug.Conn.send_resp(200, token_json_string)
    end

    %OAuth2.AccessToken{access_token: token} = Oauth.get_token!(shopid, options)
    assert token == faux_token
  end

  def endpoint_url(port), do: "http://localhost:#{port}"

end

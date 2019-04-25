defmodule Shopify.WebhookTest do
  use ExUnit.Case
  alias Shopify.Webhook

  setup do
    bypass = Bypass.open
    Application.put_env(:shopify, :oauth_site, endpoint_url(bypass.port))
    {:ok, bypass: bypass}
  end

  test "Webhook.create creates the webhook", %{bypass: bypass} do
    resource_module = Webhook
    resource_map = %{
      "topic" => "customers/create",
      "address" => "https://pen-island.com/callback",
      "format" => "json",
    }
    token = %OAuth2.AccessToken{access_token: "abc123"}
    client = %OAuth2.Client{site: endpoint_url(bypass.port), token: token}
    response_map = %{} |> Map.put(resource_module.singular_resource, resource_map)
    resource_json_string = json_string(response_map)

    Bypass.expect bypass, fn conn ->
      assert "/#{resource_module.plural_resource}.json" == conn.request_path
      assert "POST" == conn.method
      conn
      |> Plug.Conn.send_resp(201, resource_json_string)
    end

    {:ok, record} = client |> resource_module.create(resource_map)
    assert record == resource_map
  end

  test "Webhook.delete destroys the webhook", %{bypass: bypass} do
    resource_module = Webhook
    resource_id = "1337"
    resource_map = %{
      "topic" => "customers/create",
      "address" => "https://pen-island.com/callback",
      "format" => "json",
    }
    token = %OAuth2.AccessToken{access_token: "abc123"}
    client = %OAuth2.Client{site: endpoint_url(bypass.port), token: token}
    response_map = %{}
    resource_json_string = json_string(response_map)

    Bypass.expect bypass, fn conn ->
      assert "/#{resource_module.plural_resource}/#{resource_id}.json" == conn.request_path
      assert "DELETE" == conn.method
      conn
      |> Plug.Conn.send_resp(200, resource_json_string)
    end

    {:ok, empty_response} = client |> resource_module.delete(resource_id)
    assert empty_response == nil
  end

  test "authenticate_callback verifies a valid HMAC" do
    hmac = "/2hfo50LspPpum1bqeWogzu5c5Ui6HuQ4ZxvtWxM9Vw="
    {:ok, returned_digest} = Shopify.Webhook.authenticate_callback(hmac, callback_body())
    assert returned_digest == hmac
  end

  test "authenticate_callback/2 invalidates an invalid HMAC" do
    hmac = "6J11K6yc2NPxNNDeNHNnBNt1upPjKKAurDvB5v/iXjA="
    {:error, returned_digest} = Shopify.Webhook.authenticate_callback(hmac, callback_body())
    assert returned_digest != hmac
  end

  def endpoint_url(port), do: "http://localhost:#{port}"

  def json_string(json_map) do
    case Poison.encode(json_map, []) do
      {:ok, json_bitstring} -> json_bitstring |> to_string
      _ -> {:error, "oops"}
    end
  end

  def callback_body do
    {:ok, body} = File.read("test/fixtures/callback_body.json")
    body |> String.trim
  end

end

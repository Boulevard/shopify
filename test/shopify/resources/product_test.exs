defmodule Shopify.ProductTest do
  use ExUnit.Case
  alias Shopify.Product

  setup do
    bypass = Bypass.open
    Application.put_env(:shopify, :oauth_site, endpoint_url(bypass.port))
    {:ok, bypass: bypass}
  end

  test "Product.find returns the product", %{bypass: bypass} do
    resource_module = Product
    resource_map = %{"name" => "ABC-123", "color" => "black"}
    client = %OAuth2.Client{site: endpoint_url(bypass.port)}
    token = %OAuth2.AccessToken{access_token: "abc123", client: client}
    response_map = %{} |> Map.put(resource_module.singular_resource, resource_map)
    resource_json_string = Poison.Encoder.encode(response_map, []) |> to_string

    Bypass.expect bypass, fn conn ->
      assert "/#{resource_module.plural_resource}/123.json" == conn.request_path
      assert "GET" == conn.method
      conn
      |> Plug.Conn.send_resp(200, resource_json_string)
    end

    {:ok, record} = token |> resource_module.find("123")
    assert record == resource_map
  end

  test "Product.all returns all products", %{bypass: bypass} do
    resource_module = Product
    resource_map = %{"name" => "ABC-123", "color" => "black"}
    client = %OAuth2.Client{site: endpoint_url(bypass.port)}
    token = %OAuth2.AccessToken{access_token: "abc123", client: client}
    response_map = %{} |> Map.put(resource_module.plural_resource, [resource_map])
    resource_json_string = Poison.Encoder.encode(response_map, []) |> to_string

    Bypass.expect bypass, fn conn ->
      assert "/#{resource_module.plural_resource}.json" == conn.request_path
      assert "GET" == conn.method
      conn
      |> Plug.Conn.send_resp(200, resource_json_string)
    end

    {:ok, record} = token |> resource_module.all
    assert record == [resource_map]
  end

  test "Product.update updates a product", %{bypass: bypass} do
    resource_module = Product
    resource_map = %{"name" => "DEF-456", "color" => "blue"}
    client = %OAuth2.Client{site: endpoint_url(bypass.port)}
    token = %OAuth2.AccessToken{access_token: "abc123", client: client}
    response_map = %{} |> Map.put(resource_module.singular_resource, resource_map)
    resource_json_string = Poison.Encoder.encode(response_map, []) |> to_string

    Bypass.expect bypass, fn conn ->
      assert "/#{resource_module.plural_resource}/123.json" == conn.request_path
      assert "PUT" == conn.method
      conn
      |> Plug.Conn.send_resp(200, resource_json_string)
    end

    {:ok, record} = token |> resource_module.update("123", resource_map)
    assert record == resource_map
  end


  def endpoint_url(port), do: "http://localhost:#{port}"

end

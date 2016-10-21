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
    token = %OAuth2.AccessToken{access_token: "abc123"}
    client = %OAuth2.Client{site: endpoint_url(bypass.port), token: token}
    response_map = %{} |> Map.put(resource_module.singular_resource, resource_map)
    resource_json_string = json_string(response_map)

    Bypass.expect bypass, fn conn ->
      assert "/#{resource_module.plural_resource}/123.json" == conn.request_path
      assert "GET" == conn.method
      conn
      |> Plug.Conn.send_resp(200, resource_json_string)
    end

    {:ok, record} = client |> resource_module.find("123")
    assert record == resource_map
  end

  test "Product.all returns all products", %{bypass: bypass} do
    resource_module = Product
    resource_map = %{"name" => "ABC-123", "color" => "black"}
    token = %OAuth2.AccessToken{access_token: "abc123"}
    client = %OAuth2.Client{site: endpoint_url(bypass.port), token: token}
    response_map = %{} |> Map.put(resource_module.plural_resource, [resource_map])
    resource_json_string = json_string(response_map)

    Bypass.expect bypass, fn conn ->
      assert "/#{resource_module.plural_resource}.json" == conn.request_path
      assert "GET" == conn.method
      conn
      |> Plug.Conn.send_resp(200, resource_json_string)
    end

    {:ok, record} = client |> resource_module.all
    assert record == [resource_map]
  end

  test "Product.update updates a product", %{bypass: bypass} do
    resource_module = Product
    resource_map = %{"name" => "DEF-456", "color" => "blue"}
    token = %OAuth2.AccessToken{access_token: "abc123"}
    client = %OAuth2.Client{site: endpoint_url(bypass.port), token: token}
    response_map = %{} |> Map.put(resource_module.singular_resource, resource_map)
    resource_json_string = json_string(response_map)

    Bypass.expect bypass, fn conn ->
      assert "/#{resource_module.plural_resource}/123.json" == conn.request_path
      assert "PUT" == conn.method
      conn
      |> Plug.Conn.send_resp(200, resource_json_string)
    end

    {:ok, record} = client |> resource_module.update("123", resource_map)
    assert record == resource_map
  end


  def endpoint_url(port), do: "http://localhost:#{port}"

  def json_string(json_map) do
    case Poison.encode(json_map, []) do
      {:ok, json_bitstring} -> json_bitstring |> to_string
      _ -> {:error, "oops"}
    end
  end

end

defmodule Shopify.Request do
  def get(client, url_, query), do: get(client, append_query(url_, query))
  def get(client, url_) do
    headers = req_headers(client.token)
    url = prepare_url(client, url_)
    OAuth2.Client.get(client, url, headers)
  end

  defp append_query(url, []), do: url
  defp append_query(url, query) do
    query = URI.encode_query(query)
    url <> "?" <> query
  end

  def post(client, url_, data, header \\ [], opts \\ []) do
    headers = req_headers(client.token, header)
              |> req_post_headers
    url = prepare_url(client, url_)

    case apply(OAuth2.Client, :post, [client, url, data, headers, opts]) do
      {:ok, response} -> {:ok, response.body}
      {:error, error} -> {:error, error}
    end
  end

  def put(client, url_, data, header \\ [], opts \\ []) do
    headers = req_headers(client.token, header)
              |> req_post_headers
    url = prepare_url(client, url_)

    case apply(OAuth2.Client, :put, [client, url, data, headers, opts]) do
      {:ok, response} -> {:ok, response.body}
      {:error, error} -> {:error, error}
    end
  end

  def delete(client, url_, data \\ "", header \\ [], opts \\ []) do
    headers = req_headers(client.token, header)
              |> req_post_headers
    url = prepare_url(client, url_)

    case apply(OAuth2.Client, :delete, [client, url, data, headers, opts]) do
      {:ok, response} -> {:ok, response.body}
      {:error, error} -> {:error, error}
    end
  end

  defp prepare_url(client, url_) do
    case String.downcase(url_) do
      <<"http://":: utf8, _::binary>> -> url_
      <<"https://":: utf8, _::binary>> -> url_
      _ -> client.site <> url_
    end
  end

  defp req_headers(token, headers \\ []) do
    headers1 = [{"X-Shopify-Access-Token", token.access_token} | headers]
    [{"Authorization", "#{token.token_type} #{token.access_token}"}| headers1]
  end

  defp req_post_headers(headers) do
    [{"Content-Type", "application/json; charset=utf-8"} | headers]
  end
end

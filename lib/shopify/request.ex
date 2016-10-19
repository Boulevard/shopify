defmodule Shopify.Request do
  def get(token, url_, query), do: get(token, append_query(url_, query))
  def get(token, url_) do
    url = prepare_url(token, url_)
    OAuth2.AccessToken.get(token, url, req_headers(token))
  end

  defp append_query(url, []), do: url
  defp append_query(url, query) do
    query = URI.encode_query(query)
    url <> "?" <> query
  end

  def post(token, url_, data, header \\ [], opts \\ []) do
    headers = req_headers(token, header)
              |> req_post_headers
    url = prepare_url(token, url_)

    case apply(OAuth2.Request, :post, [url, data, headers, opts]) do
      {:ok, response} -> {:ok, response.body}
      {:error, error} -> {:error, error}
    end
  end

  def put(token, url_, data, header \\ [], opts \\ []) do
    headers = req_headers(token, header)
              |> req_post_headers
    url = prepare_url(token, url_)

    case apply(OAuth2.Request, :put, [url, data, headers, opts]) do
      {:ok, response} -> {:ok, response.body}
      {:error, error} -> {:error, error}
    end
  end

  # TODO: this function will need to accept an OAuth2.Client struct
  # starting with oauth2 0.7.0
  defp prepare_url(token, url_) do
    case String.downcase(url_) do
      <<"http://":: utf8, _::binary>> -> url_
      <<"https://":: utf8, _::binary>> -> url_
      _ -> token.client.site <> url_
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

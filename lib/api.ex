defmodule Shopify.Api do
  alias Shopify.{Api, Request, Collection, Models}

  def find(session, resource_module) do
    session
    |> Request.get("/#{resource_module.singular_resource}.json")
    |> unwrap(resource_module.singular_resource)
  end

  def find(session, resource_module, id) do
    session
    |> Request.get("/#{resource_module.plural_resource}/#{id}.json")
    |> unwrap(resource_module.singular_resource)
  end

  def update(session, resource_module, params) do
    session
    |> Request.put("/#{resource_module.singular_resource}.json", %{resource_module.singular_resource => params})
    |> unwrap(resource_module.singular_resource)
  end

  def update(session, resource_module, id, params) do
    session
    |> Request.put("/#{resource_module.plural_resource}/#{id}.json", %{resource_module.singular_resource => params})
    |> unwrap(resource_module.singular_resource)
  end

  defp unwrap({:ok, %OAuth2.Response{body: body}}, key) when is_map(body) do
    {:ok, body[key]}
  end
  defp unwrap(any, _), do: any
end

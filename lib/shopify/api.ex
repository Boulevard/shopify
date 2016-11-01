defmodule Shopify.Api do
  alias Shopify.Request

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

  def create(session, resource_module, params) do
    session
    |> Request.post("/#{resource_module.plural_resource}.json", %{resource_module.singular_resource => params})
    |> unwrap(resource_module.singular_resource)
  end

  def delete(session, resource_module, id) do
    session
    |> Request.delete("/#{resource_module.plural_resource}/#{id}.json")
    |> unwrap(resource_module.singular_resource)
  end

  defp unwrap({:ok, %OAuth2.Response{body: body}}, key) when is_map(body) do
    {:ok, body[key]}
  end

  # TODO:
  # OAuth2.Request seems to return a bare map on PUT calls
  # but a Response struct on GET calls. Probably need to
  # homogenize those.
  defp unwrap({:ok, body}, key) when is_map(body) do
    {:ok, body[key]}
  end
  defp unwrap(any, _), do: any

end

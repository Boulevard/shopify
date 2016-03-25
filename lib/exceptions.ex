defmodule Shopify.RequestError do
  @moduledoc "Error raised when a request to the shopify api fails."
  defexception message: "Invalid request"
end

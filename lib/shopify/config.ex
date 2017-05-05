defmodule Shopify.Config do
  @moduledoc false
  @otp_app :shopify

  def get(key) do
    case Application.get_env(@otp_app, key) do
      {:system, varname} when is_binary(key) -> System.get_env(varname)
      value -> value
    end
  end
end

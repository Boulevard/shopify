defmodule Shopify.Resource do
  alias Shopify.Request

  defimpl Enumerable, for: __MODULE__ do
    def reduce(collection, acc, fun) when is_function(fun, 2), do: Shopify.Resource.reduce(collection, acc, fun)
    def member?(_function, _value), do: {:error, __MODULE__}
    def count(_function), do: {:error, __MODULE__}
  end

  @doc false
  defmacro __using__(options) do
    import_functions = options[:import] || []
    singleton = options[:singleton] || false

    quote bind_quoted: [import_functions: import_functions, singleton: singleton] do
      alias Shopify.{Api}

      @before_compile Shopify.Resource

      def collection(session, query \\ []) do
        query = Keyword.put(query, :limit, 250)
        %Shopify.Resource{module: __MODULE__, session: session, query: query}
      end

      def all(session, query \\ []) do
        records = collection(session, query) |> Enum.to_list
        {:ok, records}
      end

      if :find in import_functions do
        if singleton do
          def find(session), do: Api.find(session, __MODULE__)
        else
          def find(session, id), do: Api.find(session, __MODULE__, id)
        end
      end

      if :update in import_functions do
        if singleton do
          def update(session, params), do: Api.update(session, __MODULE__, params)
        else
          def update(session, id, params), do: Api.update(session, __MODULE__, id, params)
        end
      end
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      def singular_resource, do: @singular
      def plural_resource, do: @plural
    end
  end

  defstruct module: nil,
            session: nil,
            query: nil,
            page: 1,
            done: false,
            remaining: []

  def reduce(col, acc, fun), do: do_reduce(col, acc, fun)

  defp do_reduce(_, {:halt, acc}, _fun),   do: {:halted, acc}
  defp do_reduce(col, {:suspend, acc}, fun), do: {:suspended, acc, &do_reduce(col, &1, fun)}
  defp do_reduce(col, {:cont, acc}, fun) do
    {col, item} = next_item(col)

    if col.done do
      {:done, acc ++ item}
    else
      do_reduce(col, fun.(item, acc), fun)
    end
  end

  defp next_item(col) do
    case col.remaining do
      [h|t] ->
        col = %__MODULE__{col| remaining: t}
        {col, h}
      [] ->
        {col, items} = fetch_next_page(col)

        if (col.done) do
          {col, items}
        else
          [next | rem] = items
          col = %__MODULE__{col| remaining: rem}
          {col, next}
        end
    end
  end

  defp fetch_next_page(col) do
    url = "/#{col.module.plural_resource}.json"
    {:ok, response} = Request.get(col.session, url, col.query ++ [page: col.page])
    response_count = Enum.count(response.body[col.module.plural_resource])
    done = response_count == 0 || response_count < 250
    col = %__MODULE__{col|page: col.page + 1, done: done}
    {col, response.body[col.module.plural_resource]}
  end
end

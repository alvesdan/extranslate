defmodule Extranslate.Cache do
  def start(_type, _args), do: Extranslate.Cache.start_link

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get(key) do
    Agent.get(__MODULE__, fn(cache) -> cache[key] end)
  end

  def set(key, value) do
    Agent.update(__MODULE__, fn(cache) ->
      Map.put_new cache, key, value
    end)
  end

  def generate_key(key, bindings) do
    items = bindings
      |> Enum.reduce([], fn({k, v}, acc) ->
        acc ++ [to_string(k), v]
      end)

    :crypto.hash(:sha256, [key] ++ items)
    |> Base.encode16
  end
end


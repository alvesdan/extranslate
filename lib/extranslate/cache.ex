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
end


defmodule Extranslate.Translator do
  alias Extranslate.Redix

  @type tag :: binary
  @type default :: binary

  def translate(tag, default \\ :missing, bindings \\ %{}) do
    translate(Extranslate.get_locale, tag, default, bindings)
  end

  defp translate(locale, tag, default, bindings) do
    key = tag_key(locale, tag)
    cache_key = Extranslate.Cache.generate_key(key, bindings)

    case translate_from_cache(cache_key) do
      nil -> translate_from_redis(key, cache_key, tag, default, bindings)
      translation -> compose(translation, bindings)
    end
  end

  defp tag_key(locale, tag) do
    "extr|" <> locale <> "|" <> tag
  end

  defp translate_from_cache(key) do
    Extranslate.Cache.get(key)
  end

  defp write_cache(key, value) do
    Extranslate.Cache.set(key, value)
  end

  defp translate_from_redis(key, cache_key, tag, default, bindings) do
    case Redix.get(key) do
      {:ok, nil} -> fallback_to(tag, default, bindings)
      {:ok, translation} ->
        write_cache(cache_key, translation)
        compose(translation, bindings)
    end
  end

  defp fallback_to(tag, default, bindings) do
    case default do
      :missing -> "MISSING TRANSLATION FOR " <> tag
      _ -> compose(default, bindings)
    end
  end

  defp compose(translation, bindings) do
    cond do
      Regex.match?(~r/%\{/, translation) ->
        Enum.reduce(bindings, translation, fn({k, v}, acc) ->
          Regex.replace(~r/%\{#{k}\}/, acc, to_string(v))
        end)
      true -> translation
    end
  end
end


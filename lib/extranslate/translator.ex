defmodule Extranslate.Translator do
  alias Extranslate.Redix

  @type tag :: binary
  @type default :: binary

  def translate(tag, default \\ :missing) do
    translate(Extranslate.get_locale, tag, default)
  end

  @spec translate(binary, binary, binary) :: binary
  defp translate(locale, tag, default) do
    key = "extr|#{locale}|#{tag}"

    case read_from_cache(key) do
      nil -> translate_from_redis(key, tag, default)
      translation -> translation
    end
  end

  defp read_from_cache(key) do
    Extranslate.Cache.get(key)
  end

  defp write_cache(key, value) do
    Extranslate.Cache.set(key, value)
  end

  defp translate_from_redis(key, tag, default) do
    case Redix.get(key) do
      {:ok, nil} -> fallback_to(tag, default)
      {:ok, translation} ->
        write_cache(key, translation)
        translation
    end
  end

  defp fallback_to(tag, default) do
    case default do
      :missing -> "MISSING TRANSLATION FOR #{tag}"
      _ -> default
    end
  end
end


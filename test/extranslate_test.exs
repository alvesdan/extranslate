defmodule ExtranslateTest do
  use ExUnit.Case
  doctest Extranslate
  alias Extranslate.Redix
  alias Extranslate.Translator

  test "it gets current locale" do
    Extranslate.put_locale "fr"
    assert Extranslate.get_locale == "fr"
  end

  test "it translates an existing tag" do
    Extranslate.put_locale "pt-BR"
    Redix.set("extr|pt-BR|home_page_title", "Incrível site!")

    assert Translator.translate("home_page_title") == "Incrível site!"
  end

  test "when no translation found" do
    assert Translator.translate("home_page_title", "The page title") == "The page title"
  end

  test "when no translation found and missing default" do
    assert Translator.translate("home_page_title") == "MISSING TRANSLATION FOR home_page_title"
  end

  test "it caches translations" do
    Redix.set("extr|en|cache_test", "Should be cached")

    Translator.translate "cache_test"

    cache_key = Extranslate.Cache.generate_key("extr|en|cache_test", %{})

    assert Extranslate.Cache.get(cache_key) == "Should be cached"
  end

  test "it translates tags with bindings" do
    Redix.set("extr|en|bindings_test", "Hi, I am %{name}")

    translation = Translator.translate "bindings_test", "Hi, %{name} here!", %{name: "Daniel"}
    assert translation == "Hi, I am Daniel"
  end

  test "it creates different caches for different bindings" do
    Redix.set("extr|en|bindings_test", "Hi, I am %{name}")

    Translator.translate "bindings_test", "Hi, %{name} here!", %{name: "Daniel"}
    Translator.translate "bindings_test", "Hi, %{name} here!", %{name: "Alves"}

    translation = Translator.translate "bindings_test", "Hi, %{name} here!", %{name: "Daniel"}
    different = Translator.translate "bindings_test", "Hi, %{name} here!", %{name: "Alves"}

    assert translation != different
  end
end


defmodule ExtranslateTest do
  use ExUnit.Case
  doctest Extranslate
  alias Extranslate.Redix

  test "it gets current locale" do
    Extranslate.put_locale "fr"
    assert Extranslate.get_locale == "fr"
  end

  test "it translates an existing tag" do
    Extranslate.put_locale "pt-BR"
    Redix.set("extr|pt-BR|home_page_title", "Incrível site!")

    assert Extranslate.Translator.translate("home_page_title") == "Incrível site!"
  end

  test "when no translation found" do
    assert Extranslate.Translator.translate("home_page_title", "The page title") == "The page title"
  end

  test "when no translation found and missing default" do
    assert Extranslate.Translator.translate("home_page_title") == "MISSING TRANSLATION FOR home_page_title"
  end

  test "it caches translations" do
    Redix.set("extr|en|cache_test", "Should be cached")

    Extranslate.Translator.translate "cache_test"

    assert Extranslate.Cache.get("extr|en|cache_test") == "Should be cached"
  end
end



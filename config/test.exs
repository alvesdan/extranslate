use Mix.Config

config :extranslate, :redix,
  host: "127.0.0.1",
  password: nil,
  size: 10,
  max_overflow: 5

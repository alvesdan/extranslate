defmodule Extranslate do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(Extranslate.Worker, [arg1, arg2, arg3]),
      supervisor(Extranslate.Redix, []),
			worker(Extranslate.Cache, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Extranslate.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @type locale :: binary

  def get_locale do
    Process.get(__MODULE__) || "en"
  end

  def put_locale(locale) when is_binary(locale) do
    Process.put(__MODULE__, locale)
  end
end

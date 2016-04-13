defmodule Extranslate.Redix do
  use Supervisor

  @redis_config Application.get_env(:extranslate, :redix)

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    pool_opts = [
      name: {:local, :redix_poolboy},
      worker_module: Redix,
      size: @redis_config[:size],
      max_overflow: @redis_config[:max_overflow],
    ]

    children = [
      :poolboy.child_spec(:redix_poolboy, pool_opts,
        Keyword.take(@redis_config, [:host, :password]))
    ]

    supervise(children, strategy: :one_for_one, name: __MODULE__)
  end

  def get(key) do
    __MODULE__.command(["GET", key])
  end

  def set(key, value) do
    __MODULE__.command(["SET", key, value])
  end

  def del(key) when is_list(key) do
    __MODULE__.command(["DEL"] ++ key)
  end

  def del(key), do: del([key])

  def keys(term) do
    __MODULE__.command(["KEYS", term])
  end

  def command(command) do
    :poolboy.transaction(:redix_poolboy, &Redix.command(&1, command))
  end

  def pipeline(commands) do
    :poolboy.transaction(:redix_poolboy, &Redix.pipeline(&1, commands))
  end
end

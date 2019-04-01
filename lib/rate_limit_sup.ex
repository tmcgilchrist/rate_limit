defmodule RateLimitSup do
  @moduledoc """
  Dynamic supervisor for Rate Limit GenServers

  A new RateLimit GenServer is started for each RateLimit.setup/3
  """
  use DynamicSupervisor

  def start_link() do
    DynamicSupervisor.start_link( __MODULE__, [], name: __MODULE__)
  end

  @doc """
  Starts a supervised RateLimit child process.
  """
  def start_child(scope, rate_limit, rate_period) do
    spec = {RateLimit, [scope, rate_limit, rate_period]}
    {:ok, _pid} = DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @doc """
  Supervisor intialisation
  """
  def init([]) do
    # Setup ETS tables
    RateLimitETS.init()

    # Setup a Dynamic Supervisor, with variable number of supervised children
    DynamicSupervisor.init(strategy: :one_for_one, extra_arguments: [])
  end
end

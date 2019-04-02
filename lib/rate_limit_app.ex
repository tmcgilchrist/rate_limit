defmodule RateLimitApp do
  @moduledoc """
  Application wrapper for RateLimit
  """

  use Application

  def start(_type, _args) do

    dispatch = :cowboy_router.compile([
      {:_,
       [
         {"/", RateLimitHttp, []}
       ]}
    ])

    {:ok, _} = :cowboy.start_clear(
      :http,
      [{:port, 8080}],
      %{:env => %{:dispatch => dispatch}})

    children = [
      %{id: RateLimitSup,
       start: {RateLimitSup, :start_link, []}}
    ]

    opts = [strategy: :one_for_one, name: Supervisor]
    Supervisor.start_link(children, opts)
  end

  def stop(_state) do
    :ok
  end
end

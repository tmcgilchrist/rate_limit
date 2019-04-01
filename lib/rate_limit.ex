defmodule RateLimit do
  @moduledoc """
  RateLimit provides an API for rate limiting HTTP requests based on the requester IP.
  """

  use GenServer

  @doc """
  Setup rate limiting for a specific scope.

  We use scopes to allow namespacing of rate limiting, so multiple consumers can
  use the same rate limit gen_server
  """
  def setup(scope, rate_limit, rate_period) do
    {:ok, _pid} = RateLimitSup.start_child(scope, rate_limit, rate_period)
    :ok
  end

  @doc """
  Perform check on requesters IP
  """
  def check(scope, ip) do
    result = RateLimitETS.update_counter(scope, ip)
    count_result(result)
  end

  @doc """
  GenServer start_link callback
  """
  def start_link([scope, limit, period]) do
    GenServer.start_link(__MODULE__, {scope, limit, period}, [])
  end

  @doc """
  Gen Server start_link callback
  """
  def start_link(scope, limit, period) do
    GenServer.start_link(__MODULE__, {scope, limit, period}, [])
  end

  @doc """
  Callback from GenServer to initialise state
  """
  def init({scope, limit, period} = state) do
    # Create and initialise counters for scope
    RateLimitETS.init_counters(scope, limit, period)

    # Use Erlang's OTP timer functionality to notify us
    # when our time period has elapsed.
    {:ok, _} = :timer.send_interval(TimeSource.interval(period), :reset_counters)
    {:ok, state}
  end

  def handle_info(:reset_counters, []) do
    {:noreply, []}
  end

  def handle_info(:reset_counters, {scope, _, _} = state) do

    # Callback handling for periodic reset_counters
    RateLimitETS.reset_counters(scope)
    {:noreply, state}
  end

  def handle_call(_, _, state) do
    {:noreply, state}
  end

  def handle_cast(_, state) do
    {:noreply, state}
  end

  @doc """
  Translate the record returned from ETS into the API types.
  """
  def count_result(r) do
    case r do
      {count, limit, next_reset} when count == limit ->
        {:rate_exceeded, 0, next_reset}
      {count, limit, next_reset} ->
        {:ok, limit - count - 1, next_reset}
      :rate_not_set ->
        :rate_not_set
    end
  end
end

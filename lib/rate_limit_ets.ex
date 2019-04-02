defmodule RateLimitETS do
  @moduledoc """
  Abstract module for interacting with ETS tables that track state for all the scopes.

  ETS (Erlang Term Storage) is an in-memory database for Erlang, it provides a robust in-memory
  store for Elixir and Erlang objects. This in-memory property and the ownership model where
  the table belongs to an individual process matches the behaviour we want from our rate
  limiting library.

  See https://elixirschool.com/en/lessons/specifics/ets/ for more details.
  """

  @doc """
  Global ETS state table name
  """
  def state_table() do
    :rate_limit_state_table
  end

  @doc """
  Initialise the ETS state table.
  """
  def init() do
    :ets.new(state_table(), [:set, :named_table, :public])
    :ok
  end

  @doc """
  Cleanup state for the ETS state table.
  """
  def cleanup() do
    :ets.delete(state_table())
  end

  def init_counters(scope, limit, period) do
    table_id = :ets.new(:scope_counters, [:set, :public])
    :ets.insert(state_table(), {scope, table_id, limit + 1, period, TimeSource.now()})
  end

  def reset_counters(scope) do
    [{scope, table_id, limit, period, _}] = :ets.lookup(state_table(), scope)
    true = :ets.delete_all_objects(table_id)
    true = :ets.insert(state_table(), {scope, table_id, limit, period, TimeSource.now()})
    :ok
  end

  def limit(scope) do
    [{_, _, limit, period, _}] = :ets.lookup(state_table(), scope)
    limit
  end

  def update_counter(scope, key) do
    case :ets.lookup(state_table(), scope) do
      [{_scope, table_id, limit, period, previous_reset}] ->
        next_reset = TimeSource.next_time(period, previous_reset)
        count = :ets.update_counter(table_id, key, {2, 1, limit, limit}, {key, 0})
        {count, limit, next_reset}

      [] ->
        :rate_not_set
    end
  end

  def lookup_counter(scope, key) do
    case :ets.lookup(state_table(), scope) do
      [{_scope, table_id, limit, period, previous_reset}] ->
        next_reset = TimeSource.next_time(period, previous_reset)

        case :ets.lookup(table_id, key) do
          [{_key, count}] ->
            {count, limit, next_reset}
          [] ->
            {0, limit, next_reset}
        end
      [] ->
        :rate_not_set
    end
  end
end

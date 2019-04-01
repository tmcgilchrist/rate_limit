defmodule TimeSource do
  @moduledoc """
  Independent abstraction over a source of Time.

  For example we might need different time sources for running production code
  and for testing purposes, or we might need to consult different time sources
  depending on the OS.

  """
  def now do
    :erlang.system_time(:millisecond)
  end

  def interval x do
    case x do                   # Define a few time periods, testing requests_per_second
      :requests_per_hour ->     # is easier than requests_per_hour.
        1000 * 60 * 60
      :requests_per_minute ->
        1000 * 60
      :requests_per_second ->
        1000
    end
  end

  def next_time(period, previous) do
    interval(period) - (TimeSource.now() - previous)
  end
end

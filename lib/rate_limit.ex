defmodule TimeSource do
  @moduledoc """
  Independent abstraction over a source of Time.

  For example we might need different time sources for running production code
  and for testing purposes, or we might need to consult different time sources
  depending on the OS.
  """
end

defmodule RateLimit do
  @moduledoc """
  RateLimit provides an API for rate limiting HTTP requests based on the requester IP.
  """

  @doc """
  Perform check on requesters IP

  ## Examples

      iex> RateLimit.check(:test_scope, IP)
      :limit_exceeded
  """
  def check(_scope, _ip) do
    :limit_exceeded
  end
end

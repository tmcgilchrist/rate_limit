defmodule RateLimitApp do
  @moduledoc """
  Application wrapper for RateLimit
  """

  use Application

  def start(_type, _args) do
    RateLimitSup.start_link()
  end

  def stop(_state) do
    :ok
  end
end

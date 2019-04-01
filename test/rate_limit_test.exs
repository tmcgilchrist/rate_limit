defmodule RateLimitTest do
  use ExUnit.Case

  doctest RateLimit

  test "checks uninitialised rate limit" do
    # Check un-initialised rate limit
    assert RateLimit.check("test_scope", "ip") == :rate_not_set
  end

end

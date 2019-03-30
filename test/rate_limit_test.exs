defmodule RateLimitTest do
  use ExUnit.Case
  doctest RateLimit

  test "checks the rate limit" do
    assert RateLimit.check(:test_scope, "127.0.0.1") == :limit_exceeded
  end
end

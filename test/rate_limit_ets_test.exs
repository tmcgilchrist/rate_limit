defmodule RateLimitETSTest do
  use ExUnit.Case

  doctest RateLimitETS

  test "check state table name" do
    assert RateLimitETS.state_table() == :rate_limit_state_table
  end
end

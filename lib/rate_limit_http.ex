defmodule RateLimitHttp do
  @doc """
  Convert RateLimit response to Map suitable for use with Phoenix, Plug, cowboy etc.
  """
  def response(response, rate) do
    case response do
      {:ok, _, _} ->
        %{:code => 200}
      {:rate_exceeded, _, _} ->
        %{:code => 429,
          :body => "Rate limit exceeded. Try again in #{rate} seconds."
         }
    end
  end
end

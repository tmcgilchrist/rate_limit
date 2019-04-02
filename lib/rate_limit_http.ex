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

  def rate_limited(req, state) do
    {ip, _req} = :cowboy_req.peer(req)

    case RateLimit.check(:my_api, ip) do
      {:rate_exceeded, _, _} ->
        IO.puts "limit_exceeded"
        {{true, RateLimit.limit(:my_api)}, req, state}
      {:ok, _, _} ->
        IO.puts "unlimited"
        {false, req, state}
      :rate_not_set ->
        IO.puts "rate_not_set"
        {false, req, state}
    end
  end

  def init(req, state) do
    {:cowboy_rest, req, state}
  end

  def content_types_provided(req, state) do
    {[{"text/plain", :hello_to_text}], req, state}
  end

  def hello_to_text(req, state) do
    IO.puts "RateLimitHttp.hello_to_text/2"
    {"REST Hello World as text!", req, state}
  end
end

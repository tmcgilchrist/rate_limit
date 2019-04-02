# RateLimit

RateLimit provides a library that stops a particular requester from making too many http
requests within a particular period of time. The main module `RateLimit` exposes a method
that tracks requests and limits it such that a particular requester can only make 100
requests per hour. After the limit has been reached, it returns a `429` with the text
`Rate limit exceeded. Try again in #{n} seconds`

Other rate limiting strategies could be implemented via this interface.

## Prerequisites

You'll need a working install of `elixir` to use this project, consult your local package
mananger for details on how to do that. For OSX I recommend using `homebrew` and running
`brew install elixir`.

## Building

``` shell
mix compile
```

## Testing

To run the project
``` shell
mix test
```

## Design

Sun Mar 31 08:02:17 2019

There are two main concerns within the code:

  1. Handling the data structure and logic for the particular requested behaviour.
  2. Handling the HTTP responses using a particular framework.

We want to clearly separate these two, further we _should_ provide a reasonable level of
configuration for things like time periods as arguments to our module.

Rate limits are divided up into intervals during which time a particular IP cannot exceed
a particular rate. Similar to how *twitter* API works.

I'm using the OTP behaviours in Elixir to build a supervision tree and to get async timeout events
for calculating intervals. This lets me separate out the logic for running multiple RateLimit scopes.


## Improvements

 * more thorough testing setup using PropEr
 * add dialyser contract types
 * metrics and logging for when clients get rate limited

## Demo

``` shell
# Startup a shell, this will also start the RateLimit application
> iex -S mix

# Setup a rate limit on :my_api
> RateLimit.setup(:my_api, 2, :requests_per_minute)

# Check manually via Elixir API
> RateLimit.check(:my_api, "127.0.0.1")
{:ok, 1, 43955}

> RateLimit.check(:my_api, "127.0.0.1")
{:ok, 0, 42844}

> RateLimit.check(:my_api, "127.0.0.1")
{:rate_exceeded, 0, 41916}

> RateLimitHttp.response({:rate_exceeded, 0, 41916}, 2)
%{body: "Rate limit exceeded. Try again in 2 seconds.", code: 429}

# Try via curl
curl http://localhost:8080/ -v

```

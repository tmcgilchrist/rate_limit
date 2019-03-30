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

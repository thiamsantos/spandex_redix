# SpandexRedix

[![Build Status](https://github.com/thiamsantos/spandex_redix/workflows/CI/badge.svg)](https://github.com/thiamsantos/spandex_redix/actions)

Tracing integration between [redix](https://hex.pm/packages/redix) and [spandex](https://hex.pm/packages/spandex).
It leverages telemetry to get the [redix](https://hex.pm/packages/redix) events and trace them with [spandex](https://hex.pm/packages/spandex).


## Installation

The package can be installed
by adding `spandex_redix` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:spandex_redix, "~> 0.1.0"}
  ]
end
```


## Usage

Configure the correct tracer to be used:

```elixir
config :spandex_redix
  service: :redix, # Optional
  tracer: MyApp.Tracer, # Required
```

Attach the telemetry handler:

```elixir
# in application.ex
:telemetry.attach_many(
  "spandex-redix-tracer",
  [
    [:redix, :pipeline],
    [:redix, :pipeline, :error]
  ],
  &SpandexRedix.handle_event/4,
  nil
)
```

The docs can
be found at [https://hexdocs.pm/spandex_redix](https://hexdocs.pm/spandex_redix).


## License

[Apache License, Version 2.0](LICENSE) © [Thiago Santos](https://github.com/thiamsantos)

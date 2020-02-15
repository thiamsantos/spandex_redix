defmodule SpandexRedix do
  @moduledoc """
  Tracing integration between redix and spandex.
  It leverages telemetry to get the redix events and trace them with spandex.

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
  """

  defmodule Error do
    @moduledoc """
    Struct used to identify the errors on datadog.
    """
    defexception [:message]
  end

  @doc """
  Telemetry handler. Attach it to the telemetry redix events in order to trace the redix calls.
  """
  def handle_event([:redix, :pipeline], measurements, metadata, _) do
    if tracer().current_trace_id([]) do
      %{elapsed_time: elapsed_time} = measurements
      %{commands: commands, start_time: start_time} = metadata

      tracer().start_span(
        "pipeline",
        start: start_time,
        completion_time: start_time + elapsed_time,
        service: service(),
        resource: parse_commands(commands)
      )

      Logger.metadata(
        trace_id: tracer().current_trace_id([]),
        span_id: tracer().current_span_id([])
      )

      tracer().finish_span([])
    end
  end

  def handle_event([:redix, :pipeline, :error], _, metadata, _) do
    if tracer().current_trace_id([]) do
      %{commands: commands, start_time: start_time, reason: reason} = metadata

      tracer().start_span(
        "pipeline",
        start: start_time,
        service: service(),
        resource: parse_commands(commands)
      )

      Logger.metadata(
        trace_id: tracer().current_trace_id([]),
        span_id: tracer().current_span_id([])
      )

      tracer().span_error(%Error{message: inspect(reason)}, nil, [])

      tracer().finish_span([])
    end
  end

  defp parse_commands(commands) do
    commands
    |> Enum.map(&List.first/1)
    |> Enum.join(", ")
  end

  defp tracer do
    Application.fetch_env!(:spandex_redix, :tracer)
  end

  defp service do
    Application.get_env(:spandex_redix, :service, :redix)
  end
end

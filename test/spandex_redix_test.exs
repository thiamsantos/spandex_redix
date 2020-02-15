defmodule SpandexRedixTest do
  use ExUnit.Case, async: true
  import Mox
  alias SpandexRedix.TracerMock

  setup :verify_on_exit!

  describe "handle_event/4" do
    test "skip pipeline span when there is no trace_id" do
      start_time = System.monotonic_time()
      elapsed_time = start_time - System.monotonic_time()
      commands = [["PING"], ["GET", "key"]]

      expect(TracerMock, :current_trace_id, fn _ -> nil end)

      SpandexRedix.handle_event(
        [:redix, :pipeline],
        %{elapsed_time: elapsed_time},
        %{commands: commands, start_time: start_time},
        nil
      )
    end

    test "span pipeline" do
      start_time = System.monotonic_time()
      elapsed_time = start_time - System.monotonic_time()
      commands = [["PING"], ["GET", "key"]]
      trace_id = "trace_id"
      span_id = "span_id"

      TracerMock
      |> expect(:current_trace_id, 2, fn [] -> trace_id end)
      |> expect(:current_span_id, fn [] -> span_id end)
      |> expect(:start_span, fn "pipeline", opts ->
        assert opts[:start] == start_time
        assert opts[:completion_time] == start_time + elapsed_time
        assert opts[:service] == :redix
        assert opts[:resource] == "PING, GET"
      end)
      |> expect(:finish_span, fn [] -> nil end)

      SpandexRedix.handle_event(
        [:redix, :pipeline],
        %{elapsed_time: elapsed_time},
        %{commands: commands, start_time: start_time},
        nil
      )

      assert Logger.metadata() == [span_id: "span_id", trace_id: "trace_id"]
    end

    test "skip pipeline error span when there is no trace_id" do
      start_time = System.monotonic_time()
      commands = [["PING"], ["GET", "key"]]
      reason = "reason"

      expect(TracerMock, :current_trace_id, fn _ -> nil end)

      SpandexRedix.handle_event(
        [:redix, :pipeline, :error],
        %{},
        %{commands: commands, start_time: start_time, reason: reason},
        nil
      )
    end

    test "span pipeline error" do
      start_time = System.monotonic_time()
      commands = [["PING"], ["GET", "key"]]
      trace_id = "trace_id"
      span_id = "span_id"
      reason = "reason"

      TracerMock
      |> expect(:current_trace_id, 2, fn [] -> trace_id end)
      |> expect(:current_span_id, fn [] -> span_id end)
      |> expect(:start_span, fn "pipeline", opts ->
        assert opts[:start] == start_time
        assert opts[:service] == :redix
        assert opts[:resource] == "PING, GET"
      end)
      |> expect(:span_error, fn error, nil, [] ->
        assert error == %SpandexRedix.Error{message: inspect("reason")}
      end)
      |> expect(:finish_span, fn [] -> nil end)

      SpandexRedix.handle_event(
        [:redix, :pipeline, :error],
        %{},
        %{commands: commands, start_time: start_time, reason: reason},
        nil
      )

      assert Logger.metadata() == [span_id: "span_id", trace_id: "trace_id"]
    end
  end
end

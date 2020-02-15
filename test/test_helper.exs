Mox.defmock(SpandexRedix.TracerMock, for: Spandex.Tracer)
Application.put_env(:spandex_redix, :tracer, SpandexRedix.TracerMock)
ExUnit.start()

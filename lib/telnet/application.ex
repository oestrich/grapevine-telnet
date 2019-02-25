defmodule Telnet.Application do
  @moduledoc false

  use Application

  @metrics Application.get_env(:telnet, :metrics)

  def start(_type, _args) do
    children = [
      cluster_supervisor(),
      metrics_plug(),
      {Telnet.ClientSupervisor, [name: {:global, Telnet.ClientSupervisor}]},
      {Telnet.Metrics.Server, []},
      {Telemetry.Poller, telemetry_opts()},
    ]

    report_errors = Application.get_env(:telnet, :errors)[:report]
    if report_errors do
      {:ok, _} = Logger.add_backend(Sentry.LoggerBackend)
    end

    Telnet.Metrics.Setup.setup()

    children = Enum.reject(children, &is_nil/1)
    opts = [strategy: :one_for_one, name: Telnet.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp cluster_supervisor() do
    topologies = Application.get_env(:telnet, :topologies)

    if topologies && Code.ensure_compiled?(Cluster.Supervisor) do
      {Cluster.Supervisor, [topologies, [name: Telnet.ClusterSupervisor]]}
    end
  end

  defp telemetry_opts() do
    [
      measurements: [
        {Telnet.Metrics.ClientInstrumenter, :dispatch_client_count, []}
      ],
      period: 10_000
    ]
  end

  defp metrics_plug() do
    if Keyword.get(@metrics, :server, true) do
      Plug.Cowboy.child_spec(scheme: :http, plug: Telnet.Endpoint, options: @metrics[:host])
    end
  end
end

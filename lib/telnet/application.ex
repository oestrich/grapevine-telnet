defmodule Telnet.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      cluster_supervisor(),
      {Telnet.ClientSupervisor, [name: {:global, Telnet.ClientSupervisor}]},
    ]

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
end

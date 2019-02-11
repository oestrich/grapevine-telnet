defmodule Telnet.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Telnet.ClientSupervisor, [name: {:global, Telnet.ClientSupervisor}]},
    ]

    opts = [strategy: :one_for_one, name: Telnet.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

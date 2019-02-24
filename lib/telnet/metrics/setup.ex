defmodule Telnet.Metrics.Setup do
  @moduledoc """
  Set up all of the local metrics
  """

  @doc false
  def setup() do
    Telnet.Metrics.ClientInstrumenter.setup()
    Telnet.Metrics.PlugExporter.setup()
  end
end

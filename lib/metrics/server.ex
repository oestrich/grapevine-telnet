defmodule Metrics.Server do
  @moduledoc """
  Client implementation to the main Metric server
  """

  @doc """
  A new web client is online
  """
  def client_online() do
    GenServer.cast({:global, {:grapvine, :metrics}}, {:client, :online, self()})
  end
end

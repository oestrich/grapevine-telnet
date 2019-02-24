defmodule Telnet.Metrics.Server do
  @moduledoc """
  Small gen server to tick and record gauge metrics
  """

  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Get the count of online clients
  """
  @spec online_clients() :: integer()
  def online_clients() do
    GenServer.call(__MODULE__, {:clients, :online})
  end

  @doc """
  Let the server know a web client came onlin
  """
  def client_online() do
    GenServer.cast(__MODULE__, {:client, :online, self()})
  end

  def init(_) do
    Process.flag(:trap_exit, true)
    {:ok, %{clients: []}}
  end

  def handle_call({:clients, :online}, _from, state) do
    {:reply, length(state.clients), state}
  end

  def handle_cast({:client, :online, pid}, state) do
    Process.link(pid)
    {:noreply, Map.put(state, :clients, [pid | state.clients])}
  end

  def handle_info({:EXIT, pid, _reason}, state) do
    state = Map.put(state, :clients, List.delete(state.clients, pid))
    {:noreply, state}
  end
end

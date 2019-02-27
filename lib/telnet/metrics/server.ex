defmodule Telnet.Metrics.Server do
  @moduledoc """
  Small gen server to tick and record gauge metrics
  """

  use GenServer

  @ets_key Telnet.Clients

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Get the count of online clients
  """
  @spec online_client_count() :: integer()
  def online_client_count() do
    GenServer.call(__MODULE__, {:clients, :online})
  end

  @doc """
  Fetch clients that are online
  """
  def online_clients() do
    keys()
    |> Enum.map(&fetch_from_ets/1)
    |> Enum.reject(&(&1 == :error))
  end

  def fetch_from_ets(pid) do
    case :ets.lookup(@ets_key, pid) do
      [{^pid, game, opened_at}] ->
        %{pid: pid, game: game, opened_at: opened_at}

      _ ->
        :error
    end
  end

  def keys() do
    key = :ets.first(@ets_key)
    keys(key, [key])
  end

  def keys(:"$end_of_table", [:"$end_of_table" | accumulator]), do: accumulator

  def keys(current_key, accumulator) do
    next_key = :ets.next(@ets_key, current_key)
    keys(next_key, [next_key | accumulator])
  end

  @doc """
  Let the server know a web client came onlin
  """
  def client_online(opts) do
    GenServer.cast(__MODULE__, {:client, :online, self(), opts, Timex.now()})
  end

  def init(_) do
    Process.flag(:trap_exit, true)
    create_table()
    {:ok, %{clients: []}}
  end

  def handle_call({:clients, :online}, _from, state) do
    {:reply, length(state.clients), state}
  end

  def handle_cast({:client, :online, pid, opts, opened_at}, state) do
    Process.link(pid)
    :ets.insert(@ets_key, {pid, Keyword.get(opts, :game), opened_at})
    {:noreply, Map.put(state, :clients, [pid | state.clients])}
  end

  def handle_info({:EXIT, pid, _reason}, state) do
    state = Map.put(state, :clients, List.delete(state.clients, pid))
    :ets.delete(@ets_key, pid)
    {:noreply, state}
  end

  defp create_table() do
    :ets.new(@ets_key, [:set, :protected, :named_table])
  end
end

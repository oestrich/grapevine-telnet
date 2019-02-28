defmodule Telnet.Presence do
  @moduledoc """
  Small gen server to tick and record gauge metrics
  """

  use GenServer

  alias __MODULE__.Implementation
  alias __MODULE__.OpenClient

  @ets_key Telnet.Presence

  defmodule OpenClient do
    @moduledoc """
    Struct for tracking open clients
    """

    defstruct [:pid, :opened_at, :game, :player_name]
  end

  @doc false
  def ets_key(), do: @ets_key

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: {:global, __MODULE__})
  end

  @doc """
  Get the count of online clients
  """
  @spec online_client_count() :: integer()
  def online_client_count() do
    GenServer.call({:global, __MODULE__}, {:clients, :online, :count})
  end

  @doc """
  Fetch clients that are online
  """
  def online_clients() do
    GenServer.call({:global, __MODULE__}, {:clients, :online})
  end

  @doc """
  Let the server know a web client came onlin
  """
  def client_online(opts) do
    GenServer.cast({:global, __MODULE__}, {:client, :online, self(), opts, Timex.now()})
  end

  def init(_) do
    Process.flag(:trap_exit, true)
    create_table()
    {:ok, %{clients: []}}
  end

  def handle_call({:clients, :online, :count}, _from, state) do
    {:reply, length(state.clients), state}
  end

  def handle_call({:clients, :online}, _from, state) do
    {:reply, Implementation.online_clients(), state}
  end

  def handle_cast({:client, :online, pid, opts, opened_at}, state) do
    Process.link(pid)

    open_client = %OpenClient{
      pid: pid,
      game: Keyword.get(opts, :game),
      opened_at: opened_at
    }

    :ets.insert(@ets_key, {pid, open_client})

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

  defmodule Implementation do
    alias Telnet.Presence

    def online_clients() do
      keys()
      |> Enum.map(&fetch_from_ets/1)
      |> Enum.reject(&(&1 == :error))
    end

    def fetch_from_ets(pid) do
      case :ets.lookup(Presence.ets_key(), pid) do
        [{^pid, open_client}] ->
          open_client

        _ ->
          :error
      end
    end

    def keys() do
      key = :ets.first(Presence.ets_key())
      keys(key, [key])
    end

    def keys(:"$end_of_table", [:"$end_of_table" | accumulator]), do: accumulator

    def keys(current_key, accumulator) do
      next_key = :ets.next(Presence.ets_key(), current_key)
      keys(next_key, [next_key | accumulator])
    end
  end
end

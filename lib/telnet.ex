defmodule Telnet do
  @moduledoc """
  An Elixir telnet client
  """

  @doc """
  Get the running version of the client
  """
  def version() do
    to_string(elem(Enum.find(:application.loaded_applications(), &(elem(&1, 0) == :telnet)), 2))
  end
end

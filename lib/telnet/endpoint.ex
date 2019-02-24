defmodule Telnet.Endpoint do
  use Plug.Router

  plug Telnet.Metrics.PlugExporter

  plug :match
  plug :dispatch

  match _ do
    send_resp(conn, 404, "")
  end
end

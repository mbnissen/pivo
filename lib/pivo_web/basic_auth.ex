defmodule PivoWeb.Plugs.BasicAuth do
  @moduledoc false
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    config = Application.get_env(:pivo, BasicAuth, %{})
    username = config[:username] || "default_user"
    password = config[:password] || "default_pass"

    case get_req_header(conn, "authorization") do
      ["Basic " <> encoded] ->
        case Base.decode64(encoded) do
          {:ok, decoded} ->
            case String.split(decoded, ":", parts: 2) do
              [^username, ^password] ->
                conn

              _ ->
                unauthorized_response(conn)
            end

          _ ->
            unauthorized_response(conn)
        end

      _ ->
        unauthorized_response(conn)
    end
  end

  defp unauthorized_response(conn) do
    conn
    |> put_resp_header("www-authenticate", "Basic realm=\"Restricted Area\"")
    |> send_resp(401, "Unauthorized")
    |> halt()
  end
end

import Ecto.Query

defmodule GuessThatGifWeb.PlayerController do
  use GuessThatGifWeb, :controller

  def register(
    conn,
    %{
      "username" => username,
      "password" => password
    }
  ) do
    result = GuessThatGif.PlayerService.create username, password

    case result do
      {:success, data} ->
        conn |> json(%{id: data.id})
      {:error, message} ->
        conn |> json(%{ok: false, error: message})
    end
  end

  def login(
    conn, %{
      "username" => _username,
      "password" => _password
    }
  ) do
    conn |> json(%{error: True})
  end

  def info(
    conn, %{
      "username" => username
    }
  ) do
    player = GuessThatGif.Player |> first(%{username: username})

    conn |> json(player)
  end
end

defmodule GuessThatGif.TenorService do
  def get_url(response_data) do
    (
      (
        response_data["results"]
        |> List.first
      )["media"]
      |> List.first
    )["gif"]["url"]
  end
end

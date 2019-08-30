defmodule GuessThatGif.StringGenerator do
    def generate(length) do
        chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" |> String.split("")

        Enum.reduce((1..length), [], fn (_i, acc) ->
            [Enum.random(chars) | acc]
          end) |> Enum.join("")
    end
end
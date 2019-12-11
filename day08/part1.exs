defmodule Day08 do
  def run(input) do
    input
    |> String.codepoints()
    |> Enum.chunk_every(25)
    |> Enum.chunk_every(6)
    |> Enum.map(&List.flatten/1)
    |> Enum.map(fn layer -> Enum.group_by(layer, & &1) end)
    |> Enum.min_by(fn %{"0" => zeroes} -> length(zeroes) end)
    |> (fn %{"1" => ones, "2" => twos} -> length(ones) * length(twos) end).()
  end
end

ExUnit.start()

defmodule Test do
  use ExUnit.Case

  test "part1" do
    IO.inspect(Day08.run(File.read!("input.txt")), label: "part1")
  end
end

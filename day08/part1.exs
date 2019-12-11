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

  def run2(input) do
    input
    |> String.codepoints()
    |> Enum.chunk_every(25 * 6)
    |> Enum.reduce(&stack/2)
    |> Enum.map(fn
      "0" -> " "
      "1" -> "*"
    end)
    |> Enum.chunk_every(25)
    |> Enum.join("\n")
  end

  def stack([], []), do: []
  def stack([h | tl1], ["2" | tl2]), do: [h | stack(tl1, tl2)]
  def stack([_ | tl1], [h | tl2]), do: [h | stack(tl1, tl2)]
end

ExUnit.start()

defmodule Test do
  use ExUnit.Case, async: false

  test "part1" do
    IO.inspect(Day08.run(File.read!("input.txt")), label: "part1")
  end

  test "part2" do
    output = Day08.run2(File.read!("input.txt"))
    IO.puts("-----------\n\n")
    IO.puts(output)
    IO.puts("\n\n-----------")
  end
end

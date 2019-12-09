defmodule Day06 do
  def run(input) do
    pairs =
      input
      |> String.trim()
      |> String.split()
      |> Enum.map(&String.split(&1, ")"))
      |> Enum.map(fn [object, satelite] -> {satelite, object} end)
      |> Enum.into(%{})

    pairs
    |> Map.keys()
    |> Enum.map(fn o -> count(pairs, o) end)
    |> Enum.sum()
  end

  def count(pairs, satelite, total \\ 0)
  def count(_pairs, nil, total), do: total - 1

  def count(pairs, satelite, total) do
    count(pairs, pairs[satelite], total + 1)
  end
end

ExUnit.start()

defmodule Test do
  use ExUnit.Case

  test "part1 examples" do
    input = """
    COM)B
    B)C
    C)D
    D)E
    E)F
    B)G
    G)H
    D)I
    E)J
    J)K
    K)L
    """

    assert Day06.run(input) == 42
  end

  test "part1" do
    IO.inspect(Day06.run(File.read!("input1.txt")), label: "part1")
  end
end

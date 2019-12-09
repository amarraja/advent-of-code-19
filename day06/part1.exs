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

  def run2(input) do
    pairs =
      input
      |> String.trim()
      |> String.split()
      |> Enum.map(&String.split(&1, ")"))
      |> Enum.map(fn [object, satelite] -> {satelite, object} end)
      |> Enum.into(%{})

    graph = :digraph.new()

    pairs
    |> Map.keys()
    |> Enum.each(fn satelite -> :digraph.add_vertex(graph, satelite) end)

    pairs
    |> Enum.each(fn {satelite, object} ->
      :digraph.add_edge(graph, satelite, object)
      :digraph.add_edge(graph, object, satelite)
    end)

    paths = :digraph.get_path(graph, "SAN", "YOU")

    # remove SAN, YOU, and first step
    Enum.count(paths) - 3
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

  test "part2 examples" do
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
    K)YOU
    I)SAN
    """

    assert Day06.run2(input) == 4
  end

  test "part2" do
    IO.inspect(Day06.run2(File.read!("input1.txt")), label: "part2")
  end
end

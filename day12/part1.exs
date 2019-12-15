defmodule Day12 do
  def get_energy(input, steps) do
    moons = parse(input)

    moved =
      for _step <- 1..steps, reduce: moons do
        acc -> step(acc)
      end

    moved
    |> Enum.map(fn {_, moon} -> moon_energy(moon) end)
    |> Enum.sum()
  end

  def step(moons) do
    Enum.map(moons, fn {id, moon} ->
      other_moons = Enum.reject(moons, fn {other, _} -> id == other end)

      new_moon =
        Enum.reduce(other_moons, moon, fn {_, {pos_o, _}}, {pos_c, vel_c} ->
          deltas =
            Enum.zip(pos_c, pos_o)
            |> Enum.map(fn x ->
              case x do
                {c, o} when c > o -> -1
                {c, o} when c < o -> 1
                _ -> 0
              end
            end)

          vs = Enum.zip(vel_c, deltas) |> Enum.map(fn {a, b} -> a + b end)
          {pos_c, vs}
        end)

      {p, v} = new_moon
      new_pos = Enum.zip(p, v) |> Enum.map(fn {a, b} -> a + b end)

      {id, {new_pos, v}}
    end)
  end

  def moon_energy({p, v}), do: absum(p) * absum(v)

  def absum(xs), do: Enum.reduce(xs, 0, fn x, acc -> acc + abs(x) end)

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      positions =
        line
        |> String.split(",")
        |> Enum.map(fn part ->
          [_, part] = String.split(part, "=")
          {int, _} = Integer.parse(part)
          int
        end)

      {positions, [0, 0, 0]}
    end)
    |> Enum.with_index()
    |> Enum.map(fn {moon, idx} -> {idx, moon} end)
    |> Map.new()
  end
end

ExUnit.start()

defmodule Test do
  use ExUnit.Case

  test "part1" do
    input = """
    <x=-2, y=9, z=-5>
    <x=16, y=19, z=9>
    <x=0, y=3, z=6>
    <x=11, y=0, z=11>
    """

    IO.inspect(Day12.get_energy(input, 1000), label: "part1")
  end

  test "examples" do
    input = """
    <x=-1, y=0, z=2>
    <x=2, y=-10, z=-7>
    <x=4, y=-8, z=8>
    <x=3, y=5, z=-1>
    """

    assert Day12.get_energy(input, 10) == 179

    input = """
    <x=-8, y=-10, z=0>
    <x=5, y=5, z=10>
    <x=2, y=-7, z=3>
    <x=9, y=-8, z=-3>
    """

    assert Day12.get_energy(input, 100) == 1940
  end
end

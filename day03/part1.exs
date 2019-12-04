defmodule Day03 do
  def run(input) do
    [a, b] =
      input
      |> String.split("\n")
      |> Enum.map(&points_for_line/1)
      |> Enum.map(&Map.keys/1)
      |> Enum.map(&MapSet.new/1)

    intersects = get_intersectings(a, b)
    manhattans = Enum.map(intersects, &manhattan/1)
    Enum.min(manhattans)
  end

  def manhattan({x, y}), do: abs(x) + abs(y)

  def get_intersectings(a, b) do
    Enum.filter(a, fn x -> Enum.member?(b, x) end)
  end

  def points_for_line(line) do
    line
    |> String.split(",")
    |> generate_points
  end

  def generate_points(commands) do
    {_heading, _steps, points} =
      commands
      |> Enum.reduce({{0, 0}, 0, %{}}, fn command, acc ->
        {dir, dist} = parse_command(command)

        for _i <- 1..dist, reduce: acc do
          {{x, y}, steps, map} ->
            new_coord =
              case dir do
                "R" -> {x + 1, y}
                "L" -> {x - 1, y}
                "U" -> {x, y + 1}
                "D" -> {x, y - 1}
              end

            {new_coord, steps + 1, Map.put(map, new_coord, steps)}
        end
      end)

    points
  end

  def parse_command(<<dir::binary-size(1)>> <> rest) do
    {dir, String.to_integer(rest)}
  end
end

ExUnit.start()

defmodule Test do
  use ExUnit.Case

  test "part1" do
    IO.inspect(Day03.run(File.read!("input1.txt")), label: "part1")
  end

  test "examples" do
    assert Day03.run("R8,U5,L5,D3\nU7,R6,D4,L4") == 6
    assert Day03.run("R75,D30,R83,U83,L12,D49,R71,U7,L72\nU62,R66,U55,R34,D71,R55,D58,R83") == 159

    assert Day03.run(
             "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51\nU98,R91,D20,R16,D67,R40,U7,R15,U6,R7"
           ) == 135
  end
end

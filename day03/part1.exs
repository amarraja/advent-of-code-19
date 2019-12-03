defmodule Day03 do
  def run(input) do
    [a, b] =
      input
      |> String.split("\n")
      |> Enum.map(&points_for_line/1)

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
    {_, points} =
      commands
      |> Enum.reduce({{0, 0}, []}, fn command, {heading, points} ->
        new_points = expand(heading, command)
        # A bit shit. Better to do this in a single pass
        new_heading = hd(Enum.reverse(new_points))
        {new_heading, Enum.concat(points, new_points)}
      end)

    points
  end

  def expand({x, y}, command) do
    {dir, dist} = parse_command(command)

    for i <- 1..dist do
      case dir do
        "R" -> {x + i, y}
        "L" -> {x - i, y}
        "U" -> {x, y + i}
        "D" -> {x, y - i}
      end
    end
  end

  def parse_command(<<dir::binary-size(1)>> <> rest) do
    {dir, String.to_integer(rest)}
  end
end

ExUnit.start()

defmodule Test do
  use ExUnit.Case

  @tag timeout: 200_000
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

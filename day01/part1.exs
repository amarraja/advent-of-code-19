defmodule Day01 do
  def part1(input) do
    input
    |> String.split()
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(&calculate_fuel/1)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> String.split()
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(&calculate_fuel/1)
    |> Enum.map(&total_fuel/1)
    |> Enum.sum()
  end

  def calculate_fuel(num) do
    trunc(num / 3) - 2
  end

  def total_fuel(module_fuel) do
    module_fuel
    |> Stream.iterate(&calculate_fuel/1)
    |> Enum.take_while(&(&1 > 1))
    |> Enum.sum()
  end
end

ExUnit.start()

defmodule Test do
  use ExUnit.Case

  test "part1" do
    File.read!("input1.txt")
    |> Day01.part1()
    |> IO.inspect(label: "part1")
  end

  test "part2" do
    File.read!("input1.txt")
    |> Day01.part2()
    |> IO.inspect(label: "part2")
  end

  test "total_fuel" do
    assert Day01.calculate_fuel(100_756) == 33583
    assert Day01.total_fuel(33583) == 50346
  end
end

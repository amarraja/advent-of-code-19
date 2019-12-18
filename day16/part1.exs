defmodule Day15 do
  def part1(input) do
    input
    |> String.to_integer()
    |> Integer.digits()
    |> fft(100)
    |> Enum.take(8)
    |> Enum.join()
  end

  def fft(input, 0) do
    input
  end

  def fft(input, count) do
    out =
      input
      |> Enum.with_index(1)
      |> Enum.map(fn {_, idx} ->
        Enum.zip(input, repeat(idx))
        |> Enum.map(fn {a, b} -> a * b end)
        |> Enum.sum()
        |> abs()
        |> rem(10)
      end)

    fft(out, count - 1)
  end

  def repeat(num) do
    [0, 1, 0, -1]
    |> Enum.map(&List.duplicate(&1, num))
    |> List.flatten()
    |> Stream.cycle()
    |> Stream.drop(1)
  end
end

ExUnit.start()

defmodule Test do
  use ExUnit.Case

  test "examples" do
    assert Day15.part1("80871224585914546619083218645595") == "24176176"
    assert Day15.part1("19617804207202209144916044189917") == "73745418"
    assert Day15.part1("69317163492948606335995924319873") == "52432133"
  end

  test "part1" do
    Day15.part1(File.read!("input.txt")) |> IO.inspect(label: "part1")
  end
end

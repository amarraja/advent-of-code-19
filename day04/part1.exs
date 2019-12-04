defmodule Day04 do
  def run(input) do
    [upper, lower] = input |> String.split("-") |> Enum.map(&String.to_integer/1)

    upper..lower
    |> Enum.filter(&validate/1)
    |> Enum.count()
  end

  def validate(int), do: validate(Integer.digits(int), %{all_increase: true, has_double: false})
  def validate([], r), do: r.all_increase && r.has_double
  def validate([h, h | _] = l, r), do: validate(tl(l), %{r | has_double: true})
  def validate([a, b | _] = l, r) when a > b, do: validate(tl(l), %{r | all_increase: false})
  def validate([_ | tl], r), do: validate(tl, r)
end

defmodule Day04Part2 do
  def run(input) do
    [upper, lower] = input |> String.split("-") |> Enum.map(&String.to_integer/1)

    upper..lower
    |> Enum.filter(&validate/1)
    |> Enum.count()
  end

  def validate(int), do: validate(Integer.digits(int), %{all_increase: true, has_double: false})
  def validate([], r), do: r.all_increase && r.has_double

  def validate([h, h | _] = l, r) do
    case count_sequence(l) do
      {2, rest} -> validate(rest, %{r | has_double: true})
      {_, rest} -> validate(rest, r)
    end
  end

  def validate([a, b | _] = l, r) when a > b, do: validate(tl(l), %{r | all_increase: false})
  def validate([_ | tl], r), do: validate(tl, r)

  def count_sequence([h | t] = l), do: count_sequence(l, h, 0)
  def count_sequence([] = t, value, acc), do: {acc, [value]}
  def count_sequence([h | t], value, acc) when h == value, do: count_sequence(t, value, acc + 1)
  def count_sequence(l, value, acc), do: {acc, [value | l]}
end

ExUnit.start()

defmodule Test do
  use ExUnit.Case

  test "validate number" do
    assert Day04.validate(111_111) == true
    assert Day04.validate(223_450) == false
    assert Day04.validate(123_789) == false
    assert Day04.validate(111_122) == true
  end

  test "part1" do
    "197487-673251"
    |> Day04.run()
    |> IO.inspect(label: "part1")
  end

  test "validate number part 2" do
    assert Day04Part2.validate(112_233) == true
    assert Day04Part2.validate(123_444) == false
    assert Day04Part2.validate(111_122) == true
  end

  test "part2" do
    "197487-673251"
    |> Day04Part2.run()
    |> IO.inspect(label: "part2")
  end
end

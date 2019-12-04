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
end

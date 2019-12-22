defmodule Day22 do
  def run(deck, commands) when is_list(deck) do
    commands
    |> String.trim()
    |> String.split("\n", trim: true)
    |> Enum.reduce(deck, &execute/2)
  end

  def run(deck, commands) do
    run(Enum.to_list(deck), commands)
  end

  def execute("deal into new stack", deck) do
    Enum.reverse(deck)
  end

  def execute("cut " <> num, deck) do
    {l, r} = Enum.split(deck, String.to_integer(num))
    Enum.concat(r, l)
  end

  def execute("deal with increment " <> increment, deck) do
    inc(deck, String.to_integer(increment), length(deck), 0, %{})
  end

  def inc([], _increment, _length, _pos, acc) do
    for k <- Map.keys(acc) |> Enum.sort(), into: [], do: acc[k]
  end

  def inc([h | rest], increment, length, pos, acc) do
    inc(rest, increment, length, rem(pos + increment, length), Map.put(acc, pos, h))
  end
end

ExUnit.start()

defmodule Test do
  use ExUnit.Case

  test "examples" do
    deck =
      Day22.run(
        0..9,
        """
        deal with increment 7
        deal into new stack
        deal into new stack
        """
      )

    assert deck == [0, 3, 6, 9, 2, 5, 8, 1, 4, 7]

    deck =
      Day22.run(
        0..9,
        """
        cut 6
        deal with increment 7
        deal into new stack
        """
      )

    assert deck == [3, 0, 7, 4, 1, 8, 5, 2, 9, 6]

    deck =
      Day22.run(
        0..9,
        """
        deal into new stack
        cut -2
        deal with increment 7
        cut 8
        cut -4
        deal with increment 7
        cut 3
        deal with increment 9
        deal with increment 3
        cut -1
        """
      )

    assert deck == [9, 2, 5, 8, 1, 4, 7, 0, 3, 6]
  end

  test "part1" do
    Day22.run(0..10006, File.read!("input.txt"))
    |> Enum.find_index(fn x -> x == 2019 end)
    |> IO.inspect(label: "part1")
  end
end

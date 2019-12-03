defmodule Day02 do
  def parse(input) do
    input |> String.split(",") |> Enum.map(&String.to_integer/1)
  end

  def run(input) when is_binary(input) do
    input |> parse |> interpret()
  end

  def run(input, noun, verb) do
    input |> parse |> run_with_noun_verb(noun, verb)
  end

  def run_to_target(input, target) do
    cmds = parse(input)
    combos = for noun <- 1..100, verb <- 1..100, do: {noun, verb}

    Enum.reduce_while(combos, nil, fn {noun, verb} = pair, acc ->
      case run_with_noun_verb(cmds, noun, verb) do
        ^target -> {:halt, pair}
        _ -> {:cont, acc}
      end
    end)
  end

  def run_with_noun_verb([a, _b, _c | tl], noun, verb) do
    interpret([a, noun, verb | tl], 0)
  end

  def interpret(acc) do
    interpret(acc, 0)
  end

  def interpret(acc, pos) do
    commands = acc |> Enum.drop(pos) |> Enum.take(4)

    case commands do
      [op, _, _, _ | _] = cmd when op in [1, 2] ->
        result = apply_operation(cmd, acc)
        interpret(result, pos + 4)

      [99 | _] ->
        hd(acc)

      seq ->
        raise "Unknown command sequence: #{inspect(seq)}"
    end
  end

  def apply_operation([op, index_a, index_b, dst], acc) do
    a = Enum.at(acc, index_a)
    b = Enum.at(acc, index_b)

    result =
      case op do
        1 -> a + b
        2 -> a * b
      end

    List.update_at(acc, dst, fn _ -> result end)
  end
end

ExUnit.start()

defmodule Test do
  use ExUnit.Case

  test "first examples" do
    assert Day02.run("1,9,10,3,2,3,11,0,99,30,40,50") == 3500
    assert Day02.run("1,0,0,0,99") == 2
  end

  test "part1" do
    IO.inspect(Day02.run(File.read!("input1.txt"), 12, 2), label: "part1")
  end

  test "part2" do
    {noun, verb} = result = Day02.run_to_target(File.read!("input1.txt"), 19_690_720)

    IO.inspect(result, label: "part2")
    IO.inspect(100 * noun + verb, label: "part2")
  end
end

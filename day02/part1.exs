defmodule Day02 do
  def run(input) when is_binary(input) do
    input
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> run()
  end

  def run(input, noun, verb) do
    [a, b, c | tl] =
      input
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    commands = [a, noun, verb] ++ tl

    interpret(commands, 0)
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
end

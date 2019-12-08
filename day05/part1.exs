defmodule Day05 do
  def parse(input) do
    input |> String.split(",") |> Enum.map(&String.to_integer/1)
  end

  def run(input) when is_binary(input) do
    input |> parse |> interpret()
  end

  def run_with_noun_verb([a, _b, _c | tl], noun, verb) do
    interpret([a, noun, verb | tl], 0, [])
  end

  def interpret(acc) do
    interpret(acc, 0, [])
  end

  def interpret(acc, pos, output) do
    [command_bits | rest] = Enum.drop(acc, pos)
    command_data = extract_command(command_bits)

    case command_data do
      {command, arity, modes} when command in [:add, :mul] ->
        [a, b, dest] = Enum.take(rest, arity)
        [a, b] = get_data_bits([a, b], modes, acc)

        result =
          case command do
            :add -> a + b
            :mul -> a * b
          end

        new_app = List.update_at(acc, dest, fn _ -> result end)
        interpret(new_app, pos + arity + 1, output)

      {:input, arity, _modes} ->
        [dest] = Enum.take(rest, arity)
        new_app = List.update_at(acc, dest, fn _ -> 1 end)
        interpret(new_app, pos + arity + 1, output)

      {:output, arity, modes} ->
        data = Enum.take(rest, arity)
        [result] = get_data_bits(data, modes, acc)
        interpret(acc, pos + arity + 1, [result | output])

      [99 | _] ->
        {hd(acc), output}

      seq ->
        raise "Unknown command sequence: pos: #{pos}, output: #{output}, #{inspect(seq)}"
    end
  end

  def get_data_bits(registers, modes, app) do
    registers
    |> Enum.with_index()
    |> Enum.map(fn {reg, index} ->
      mode = Enum.at(modes, index) || :positional
      if mode == :positional, do: Enum.at(app, reg), else: reg
    end)
  end

  def extract_command(int) do
    digits = int |> Integer.digits() |> Enum.reverse()

    cmdlist =
      case digits do
        [a, 0 | tl] -> [a | tl]
        list -> list
      end

    case map_command(cmdlist) do
      nil -> [int]
      x -> x
    end
  end

  @cmdmap %{
    1 => {:add, 3},
    2 => {:mul, 3},
    3 => {:input, 1},
    4 => {:output, 1}
  }

  def map_command([id | tl]) when id in 1..4 do
    {cmd, arity} = @cmdmap[id]

    modes =
      Enum.map(tl, fn
        0 -> :positional
        1 -> :immediate
      end)

    {cmd, arity, modes}
  end

  def map_command(_), do: nil
end

ExUnit.start()

defmodule Test do
  use ExUnit.Case

  test "first examples" do
    assert {3500, []} = Day05.run("1,9,10,3,2,3,11,0,99,30,40,50")
    assert {2, []} = Day05.run("1,0,0,0,99")
  end

  test "commands" do
    assert {:mul, 3, []} = Day05.extract_command(2)
    assert {:mul, 3, [:immediate]} = Day05.extract_command(102)
    assert {:mul, 3, [:positional, :immediate]} = Day05.extract_command(1002)
  end

  test "part1" do
    {_, output} = Day05.run(File.read!("input1.txt"))
    IO.inspect(output, label: "part1")
    IO.inspect(hd(output), label: "part1")
  end
end

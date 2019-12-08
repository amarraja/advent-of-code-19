defmodule Day05 do
  def parse(input) do
    input |> String.split(",") |> Enum.map(&String.to_integer/1)
  end

  def run(input, id) when is_binary(input) do
    input |> parse |> interpret(id)
  end

  def run_with_noun_verb([a, _b, _c | tl], noun, verb, id) do
    interpret([a, noun, verb | tl], 0, [], id)
  end

  def interpret(acc, id) do
    interpret(acc, 0, [], id)
  end

  def interpret(acc, pos, output, id) do
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
        interpret(new_app, pos + arity + 1, output, id)

      {:input, arity, _modes} ->
        [dest] = Enum.take(rest, arity)
        new_app = List.update_at(acc, dest, fn _ -> id end)
        interpret(new_app, pos + arity + 1, output, id)

      {:output, arity, modes} ->
        data = Enum.take(rest, arity)
        [result] = get_data_bits(data, modes, acc)
        interpret(acc, pos + arity + 1, [result | output], id)

      {:jump_if_true, arity, modes} ->
        [input, new_pos] = Enum.take(rest, arity)
        [input, new_pos] = get_data_bits([input, new_pos], modes, acc)

        if input == 0 do
          interpret(acc, pos + arity + 1, output, id)
        else
          interpret(acc, new_pos, output, id)
        end

      {:jump_if_false, arity, modes} ->
        [input, new_pos] = Enum.take(rest, arity)
        [input, new_pos] = get_data_bits([input, new_pos], modes, acc)

        if input == 0 do
          interpret(acc, new_pos, output, id)
        else
          interpret(acc, pos + arity + 1, output, id)
        end

      {:less_than, arity, modes} ->
        [a, b, dst] = Enum.take(rest, arity)
        [a, b] = get_data_bits([a, b], modes, acc)

        val = if a < b, do: 1, else: 0
        acc = List.update_at(acc, dst, fn _ -> val end)
        interpret(acc, pos + arity + 1, output, id)

      {:equals, arity, modes} ->
        [a, b, dst] = Enum.take(rest, arity)
        [a, b] = get_data_bits([a, b], modes, acc)

        val = if a == b, do: 1, else: 0
        acc = List.update_at(acc, dst, fn _ -> val end)
        interpret(acc, pos + arity + 1, output, id)

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
    4 => {:output, 1},
    5 => {:jump_if_true, 2},
    6 => {:jump_if_false, 2},
    7 => {:less_than, 3},
    8 => {:equals, 3}
  }

  def map_command([id | tl]) when id in 1..8 do
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
    assert {3500, []} = Day05.run("1,9,10,3,2,3,11,0,99,30,40,50", 1)
    assert {2, []} = Day05.run("1,0,0,0,99", 1)
  end

  test "commands" do
    assert {:mul, 3, []} = Day05.extract_command(2)
    assert {:mul, 3, [:immediate]} = Day05.extract_command(102)
    assert {:mul, 3, [:positional, :immediate]} = Day05.extract_command(1002)
  end

  test "part1" do
    {_, output} = Day05.run(File.read!("input1.txt"), 1)
    IO.inspect(output, label: "part1")
    IO.inspect(hd(output), label: "part1")
  end

  test "part2 examples" do
    program = """
    3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
    1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
    999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99
    """

    program = program |> String.replace("\n", "") |> String.trim()

    assert {_, [999]} = Day05.run(program, 7)
    assert {_, [1000]} = Day05.run(program, 8)
    assert {_, [1001]} = Day05.run(program, 9)
  end

  test "part2" do
    {_, output} = Day05.run(File.read!("input1.txt"), 5)

    IO.inspect(output, label: "part2")
    IO.inspect(hd(output), label: "part2")
  end
end

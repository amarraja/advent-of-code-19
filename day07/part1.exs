defmodule Day07 do
  def parse(input) do
    input |> String.split(",") |> Enum.map(&String.to_integer/1)
  end

  def run(program, input) when is_binary(program) do
    program |> parse |> interpret([input])
  end

  def interpret(acc, inputs) do
    interpret(acc, 0, [], inputs)
  end

  def interpret(acc, pos, output, inputs) do
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
        interpret(new_app, pos + arity + 1, output, inputs)

      {:input, arity, _modes} ->
        [dest] = Enum.take(rest, arity)
        [input | inputs] = inputs
        new_app = List.update_at(acc, dest, fn _ -> input end)
        interpret(new_app, pos + arity + 1, output, inputs)

      {:output, arity, modes} ->
        data = Enum.take(rest, arity)
        [result] = get_data_bits(data, modes, acc)
        interpret(acc, pos + arity + 1, [result | output], inputs)

      {:jump_if_true, arity, modes} ->
        [input, new_pos] = Enum.take(rest, arity)
        [input, new_pos] = get_data_bits([input, new_pos], modes, acc)

        if input == 0 do
          interpret(acc, pos + arity + 1, output, inputs)
        else
          interpret(acc, new_pos, output, inputs)
        end

      {:jump_if_false, arity, modes} ->
        [input, new_pos] = Enum.take(rest, arity)
        [input, new_pos] = get_data_bits([input, new_pos], modes, acc)

        if input == 0 do
          interpret(acc, new_pos, output, inputs)
        else
          interpret(acc, pos + arity + 1, output, inputs)
        end

      {:less_than, arity, modes} ->
        [a, b, dst] = Enum.take(rest, arity)
        [a, b] = get_data_bits([a, b], modes, acc)

        val = if a < b, do: 1, else: 0
        acc = List.update_at(acc, dst, fn _ -> val end)
        interpret(acc, pos + arity + 1, output, inputs)

      {:equals, arity, modes} ->
        [a, b, dst] = Enum.take(rest, arity)
        [a, b] = get_data_bits([a, b], modes, acc)

        val = if a == b, do: 1, else: 0
        acc = List.update_at(acc, dst, fn _ -> val end)
        interpret(acc, pos + arity + 1, output, inputs)

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
  end
end

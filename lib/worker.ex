 defmodule Worker do
    def run(arg) do
        [k, start_point, work_unit, server] = arg
        list = start_point..start_point+work_unit+k-2 |> Enum.to_list

        squared_list = Enum.map(list, &(:math.pow(&1, 2)))

        Enum.each 0..work_unit-1, fn index ->
            if Enum.slice(squared_list, index, k)
            |> Enum.sum
            |> is_perfect_square? do
                Counter.put(server, Enum.fetch!(list, index)) # Use Enum.fetch!/2 and not Enum.fetch/2
            end
        end
    end

    defp is_perfect_square?(num) do
        :math.sqrt(num) |> :erlang.trunc |> :math.pow(2) == num
    end
end

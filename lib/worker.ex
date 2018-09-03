defmodule Worker do
    use Task

    def start_link(arg) do
        Task.start_link(__MODULE__, :run, [arg])
    end

    def run(arg) do
        [k, start_point, work_unit, counter_agent] = arg

        # Generate a list of numbers to be checked
        list = start_point..start_point+work_unit+k-2 |> Enum.to_list
        # IO.puts inspect list

        # TODO Check performace with fn x -> x * x instead of :math.pow/2
        squared_list = Enum.map(list, &(:math.pow(&1, 2)))
        # IO.puts inspect squared_list

        Enum.each 0..work_unit-1, fn index ->
            if Enum.slice(squared_list, index, k) 
            |> Enum.sum 
            |> is_perfect_square? do
                Counter.put(counter_agent, Enum.fetch!(list, index)) # Use Enum.fetch!/2 and not Enum.fetch/2
            end
        end

        # Test code
        # Enum.each 0..work_unit-1, fn index ->
        #     sq_list = Enum.slice(squared_list, index, k) 
        #     sum = Enum.sum(sq_list)
        #     sq_root = :math.sqrt(sum)
        #     IO.puts "List: #{inspect sq_list} Sum: #{sum} Sq root: #{sq_root}"
        # end
    end

    # TODO check if there's a better way to do this
    defp is_perfect_square?(num) do
        :math.sqrt(num) |> :erlang.trunc |> :math.pow(2) == num
    end
end
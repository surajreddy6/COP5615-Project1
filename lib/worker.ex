 defmodule Worker do
   use GenServer


   def start_link(opts)  do
       GenServer.start_link(__MODULE__, :ok, opts)
   end

   def compute(server, args) do
       GenServer.cast(server, {:compute, args})
   end


   def init(:ok) do
     {:ok, []}
   end

   def handle_cast({:compute, args}, state) do
       [k, start_point, end_point, server] = args
       list = start_point..end_point+k |> Enum.to_list
       squared_list = Enum.map(list, &(:math.pow(&1, 2)))

       Enum.map 0..(end_point - start_point), fn index ->
           if Enum.slice(squared_list, index, k)
           |> Enum.sum
           |> is_perfect_square? do
               Counter.put(server, Enum.fetch!(list, index)) # Use Enum.fetch!/2 and not Enum.fetch/2
           end
       end
       {:noreply, state}
   end

    defp is_perfect_square?(num) do
        :math.sqrt(num) |> :erlang.trunc |> :math.pow(2) == num
    end
end

defmodule Child do
    use GenServer

    def start_link(opts)  do
        GenServer.start_link(__MODULE__, :ok, opts)
    end

    def compute(server, args) do
        GenServer.cast(server, {:compute, args})
    end

    # Server API
    def init(:ok) do
        {:ok, []}
    end

    def handle_cast({:compute, args}, state) do
        [start_point, end_point, k, work_unit, listener] = args
        {:ok, counter} = Counter.start_link([])
        start_points = :lists.seq(start_point, end_point, work_unit)
        tasks = Enum.map(start_points, &Task.async(Worker, :run, [[k, &1, work_unit, counter]]))
        Enum.map(tasks, &Task.await(&1, :infinity)) # Large timeout
        state = Counter.get(counter)
        Listener.update(listener, state)

        {:noreply, state}
    end
end

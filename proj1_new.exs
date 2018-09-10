# taking in commandline args
[n, k] = System.argv
{n, _} = Integer.parse(n)
{k, _} = Integer.parse(k)

total_process_limit = 10000

num_servers = 8

server_process_limit = total_process_limit / num_servers |> :math.ceil |> Kernel.trunc

work_unit =
  if n > 150 do
    ((n / num_servers |> :math.ceil |> Kernel.trunc) / server_process_limit) |>:math.ceil |> Kernel.trunc
  else
    5
  end

# calculating start and end points for each child node based on input "n"
start_points = :lists.seq(1, n, n/num_servers |> :math.ceil |> Kernel.trunc)


# if length(start_points) < num_servers do
#   num_servers = length(start_points)
# end


compute_end_points = fn (s, num_servers, n) ->
    k = (n / num_servers |> :math.ceil |> Kernel.trunc) - 1
    if s + k > n do
        n
    else
        s + k
    end
end
end_points = Enum.map(start_points, &(compute_end_points.(&1, num_servers, n)))
# to calculate the CPU/Real Time ratio
:erlang.statistics(:runtime)
:erlang.statistics(:wall_clock)

# starting GenServer on Listener
{:ok, listener} = Listener.start_link([])

# sending start point values to all async Tasks
# start_points = :lists.seq(1, n, work_unit)
# tasks = Enum.map(start_points, &Task.async(Worker, :run, [[k, &1, work_unit, server]]))
# Enum.map(tasks, &Task.await(&1, 500000)) # Large timeout

# start num_servers GenServers
pids = Enum.map(0..num_servers-1, fn (i) ->
  Child.start_link([])
end)

# send start and end values to each child node
Enum.map(0..length(start_points) - 1, fn (i) ->
    start_point = Enum.fetch!(start_points, i)
    end_point = Enum.fetch!(end_points, i)
    {:ok, server_pid} = Enum.fetch!(pids, i)
    Child.compute(server_pid, [start_point, end_point, k, work_unit, listener])
end)

# wait for async node to complete computation
Enum.map(0..num_servers-1, fn (i) ->
    {:ok, pid} = Enum.fetch!(pids, i)
    state_after_exec = :sys.get_state(pid, :infinity)
end)

{_, t1} = :erlang.statistics(:runtime) # CPU time
{_, t2} = :erlang.statistics(:wall_clock) # Real time

# getting final result from "Listener"
result = Listener.get(listener)
result = List.flatten(result)
sorted_result = Enum.sort(result)
Enum.map(sorted_result, &IO.puts(&1))

IO.puts("CPU time: #{t1} ms Real time: #{t2} ms Time ratio: #{t1/t2}")

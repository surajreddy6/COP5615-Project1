# taking in commandline args
[n, k] = System.argv
{n, _} = Integer.parse(n)
{k, _} = Integer.parse(k)

# work_unit for each node
work_unit =
  if n > 100 do
    100
  else
    5
  end

# to calculate the CPU/Real Time ratio
:erlang.statistics(:runtime)
:erlang.statistics(:wall_clock)

# starting GenServer on counter
{:ok, server} = Counter.start_link([])

# sending start point values to all async Tasks
start_points = :lists.seq(1, n, work_unit)
tasks = Enum.map(start_points, &Task.async(Worker, :run, [[k, &1, work_unit, server]]))
Enum.map(tasks, &Task.await(&1, 500000)) # Large timeout

{_, t1} = :erlang.statistics(:runtime) # CPU time
{_, t2} = :erlang.statistics(:wall_clock) # Real time

# getting final result from the "Counter"
result = Counter.get(server)
sorted_list = Enum.sort(result)
Enum.each sorted_list, &IO.puts(&1)

IO.puts("CPU time: #{t1} ms Real time: #{t2} ms Time ratio: #{t1/t2}")

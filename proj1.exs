[n, k] = System.argv
{n, _} = Integer.parse(n)
{k, _} = Integer.parse(k)

work_unit = 100

:erlang.statistics(:runtime)
:erlang.statistics(:wall_clock)

{:ok, agent} = Counter.start_link([])

start_points = :lists.seq(1, n, work_unit)

tasks = Enum.map(start_points, &Task.async(Worker, :run, [[k, &1, work_unit, agent]]))
Enum.map(tasks, &Task.await(&1, 500000)) # Large timeout

{_, t1} = :erlang.statistics(:runtime) # CPU time
{_, t2} = :erlang.statistics(:wall_clock) # Real time

result = Counter.get(agent)
sorted_list = Enum.sort(result)
Enum.each sorted_list, &IO.puts(&1)

IO.puts("CPU time: #{t1} ms Real time: #{t2} ms Time ratio: #{t1/t2}")
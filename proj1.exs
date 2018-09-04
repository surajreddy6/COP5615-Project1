[n, k] = System.argv
{n, _} = Integer.parse(n)
{k, _}= Integer.parse(k)


worker_unit = 45
{:ok, counter_pid} = Counter.start_link([])

start_list = :lists.seq(1, n, worker_unit)

wrapper = fn (start_list, k, worker_unit, counter_pid) ->
  Enum.each start_list, fn start ->
    #TODO: Have to increase timeout for larger numbers
    Task.async(Worker, :run, [[k, start, worker_unit, counter_pid]]) |> Task.await
  end
end

{time, _} = :timer.tc(wrapper, [start_list, k, worker_unit, counter_pid])

# Enum.each start_list, fn start ->
#   #TODO: Have to increase timeout for larger numbers
#   Task.async(Worker, :run, [[k, start, worker_unit, counter_pid]]) |> Task.await
# end

output_list = Counter.get(counter_pid)


final_output = Enum.sort(output_list)

Enum.each final_output, fn i ->
  IO.puts(i)
end

IO.puts("Time: #{time/1000} milliseconds")

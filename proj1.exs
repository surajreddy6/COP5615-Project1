IO.puts "WARNING: Running as a single process"

[w, k] = System.argv
{w, _} = Integer.parse(w)
{k, _} = Integer.parse(k)

s = 1

{:ok, agent} = Counter.start_link([])

{time, :ok} = :timer.tc(Worker, :run, [[k, s, w, agent]])

pretty_print = fn list ->
    sorted_list = Enum.sort(list)
    Enum.each sorted_list, &IO.puts(&1)
end

pretty_print.(Counter.get(agent))

# IO.puts "Time to execute: #{time} microseconds"




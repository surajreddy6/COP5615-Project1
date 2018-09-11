# COP5615 - Project 1

Find _k_ consecutive numbers whose sum of squares is a perfect square.

## Getting Started

**Input :** Two integers _N_ and _k_. The program finds all _k_ consecutive numbers starting at 1 and up to _N_, such that the sum of squares is itself a perfect square.

**Output :** The first number in the sequence for each set of consecutive integers printed on independent lines.

#### Running on a single machine

**Example :**
```
$ mix run proj1.exs 10000 26
25
301
454
3850
```
#### Running on multiple machines

* Launch an Erlang VM on each machine using `iex --name <node_name>@<node_ip_address> --cookie <cookie_name> -S mix`
* Update `node_list` in `proj1_dist.exs`
* On the supervisor node execute `elixir --name <supervisor_name>@<supervisor_ip_address> --cookie <cookie_name> -S mix run proj1_dist.exs N k `

**Example :**
```
# on child nodes
$ iex --name foo --cookie monster -S mix

# on supervisor node
$ elixir --name boss --cookie monster -S mix run proj1_dist.exs 40 24
1
9
20
25
```
## Running tests

Run the tests using `mix test`

## Results

**Work Unit :** Through trial and error the optimal work unit size was found to be 100 for a large input _N_. To accomodate small input sizes we take the work unit size to be 5, again found using trial and error.

**Result for _N_ = 1000000 and _k_ = 4 :**
```
$ mix run proj1.exs 1000000 4
CPU time: 3505 ms Real time: 458 ms Time ratio: 7.652838427947598
```
**Timing Result**
```
$ time mix run proj1.exs 1000000 4
mix run proj1.exs 1000000 4  4.52s user 0.08s system 449% cpu 1.023 total
```
**Largest Problem Solved :** _N_ = 1000000000 _k_ = 26. See `large_output.txt` for output.


## Authors

* **Aditi Malladi UFID: 9828-6321**
* **Suraj Kumar Reddy Thanugundla UFID: 3100-9916**

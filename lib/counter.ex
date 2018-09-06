defmodule Counter do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def put(server, value) do
    GenServer.call(server, {:update, value})
  end

  def get(server) do
    GenServer.call(server, {:retrieve})
  end

  # Server API
  def init(:ok) do
    {:ok, []}
  end

  def handle_call({:update, value}, _from, values) do
    {:reply, value, [value | values]}
  end

  def handle_call({:retrieve}, _from, values) do
    {:reply, values, values}
  end
end

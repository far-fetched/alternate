defmodule Alternate do
  use GenServer


  def start_link(initial) do
    GenServer.start_link(__MODULE__, initial)
  end

  def schedule_next do
    IO.puts 'schedule start'
    Process.send_after(self(), :toggle, 1000)
    IO.puts 'schedule end'
  end

  @impl true
  def init(value) do
    IO.puts 'init start'
    schedule_next()
    IO.puts 'init end'

    {:ok, value}
  end

  @impl true
  def handle_info(:toggle, state) do
    IO.puts 'state taki:'
    IO.puts state
    IO.puts 'end'
    schedule_next()
    IO.puts 'after reschedule'
    {:noreply, !state}
  end
end

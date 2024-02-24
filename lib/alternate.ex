defmodule Alternate do
  use GenServer


  def start_link(initial) do
    GenServer.start_link(__MODULE__, initial)
  end

  def schedule_next(step) do
    IO.puts 'schedule start'
    Process.send_after(self(), {:toggle, step}, 1000)
    IO.puts 'schedule end'
  end

  @impl true
  def init(value) do
    IO.puts 'init start'
    {:ok, enable} = Circuits.GPIO.open("GPIO12", :output)
    {:ok, dir} = Circuits.GPIO.open("GPIO13", :output)
    {:ok, step} = Circuits.GPIO.open("GPIO19", :output)
    Circuits.GPIO.write(enable, 1)
    Circuits.GPIO.write(dir, 1)
    #step = [1]
    schedule_next(step)
    IO.puts 'init end'

    {:ok, value}
  end

  @impl true
  def handle_info({:toggle, step}, state) do
    IO.puts 'state taki:'
    IO.puts step
    Circuits.GPIO.write(step, state)
    IO.puts state
    IO.puts 'end'
    schedule_next(step)
    IO.puts 'after reschedule'
    {:noreply, !state}
  end
end

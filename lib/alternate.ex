defmodule Alternate do
  use GenServer


  def start_link(_) do
    GenServer.start_link(__MODULE__, false)
  end

  def schedule_next do
    IO.puts 'schedule start'
    Process.send_after(self(), :toggle, 5000)
    IO.puts 'schedule end'
  end

  @impl true
  def init(value) do
    IO.puts 'init start'
    schedule_next()
    IO.puts 'init end'
    {:ok, value }
  end

  @impl true
  def handle_info(:toggle, value) do
    #IO.puts 'state taki:'
    IO.puts value

    {:ok, enable} = Circuits.GPIO.open("GPIO12", :output)
    {:ok, dir} = Circuits.GPIO.open("GPIO13", :output)
    {:ok, step} = Circuits.GPIO.open("GPIO19", :output)
    Circuits.GPIO.write(enable, 1)
    Circuits.GPIO.write(dir, 1)

    Enum.each(0..50, fn(_x) ->
      Circuits.GPIO.write(step, 0)
      :timer.sleep(2);
      Circuits.GPIO.write(step, 1)
      :timer.sleep(2);
    end)
    #IO.puts 'end'
    schedule_next()
    #IO.puts 'after reschedule'
    {:noreply, !value}
  end
end

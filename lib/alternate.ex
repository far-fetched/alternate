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
    {:ok, enable} = Circuits.GPIO.open("GPIO12", :output)
    {:ok, dir} = Circuits.GPIO.open("GPIO13", :output)
    {:ok, step} = Circuits.GPIO.open("GPIO19", :output)

    schedule_next()
    IO.puts 'init end'
    {:ok, { value, enable, dir, step }}
  end

  @impl true
  def handle_info(:toggle, { value, enable, dir, step }) do
    #IO.puts 'state taki:'
    IO.puts value

    Circuits.GPIO.write(enable, 1)
    Circuits.GPIO.write(dir, value)

    Enum.each(0..50, fn(_x) ->
      Circuits.GPIO.write(step, 0)
      :timer.sleep(2);
      Circuits.GPIO.write(step, 1)
      :timer.sleep(2);
    end)
    #IO.puts 'end'
    schedule_next()
    #IO.puts 'after reschedule'
    {:noreply, { !value, enable, dir, step }}
  end
end

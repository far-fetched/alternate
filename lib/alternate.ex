defmodule Alternate do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, false)
  end

  def schedule_next do
    IO.puts(~c"schedule start")

    Process.send_after(self(), :toggle, 5000)
    IO.puts(~c"schedule end")
  end

  @impl true
  def init(value) do
    IO.puts(~c"init start")
    data = Alternate.GpioService.read_config() |> Alternate.GpioService.open_gpios()
    schedule_next()
    IO.puts(~c"init end")
    {:ok, {data}}
  end

  @impl true
  def handle_info(:toggle, {data}) do
    IO.puts('data')
    Alternate.GpioService.execute_action("on", 12, data)
    Alternate.GpioService.execute_action("rising_edge", 19, data)
    #Circuits.GPIO.write(enable, 1)
    #Circuits.GPIO.write(dir, (value && 1) || 0)

    #Enum.each(0..50, fn _x ->
      #Circuits.GPIO.write(step, 0)
      #:timer.sleep(2)
      #Circuits.GPIO.write(step, 1)
      #:timer.sleep(2)
    #end)

    schedule_next()
    {:noreply, {data}}
  end
end

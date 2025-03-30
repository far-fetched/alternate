defmodule Alternate.Job do
  alias Alternate.GpioService
  use GenServer

  def start_link({gpios, job}) do
    GenServer.start_link(__MODULE__, {gpios, job})
  end

  def dispatch_job(job) do
    case job["scheduler"]["type"] do
      "interval" ->
        IO.puts(~c"schedule interval")
        Process.send_after(self(), :toggle, job["scheduler"]["sec"])

      "delay" ->
        Process.send_after(self(), :toggle, 1000)
    end
  end

  @impl true
  def init({gpios, job}) do
    dispatch_job(job)
    IO.inspect(~c"init job")
    IO.inspect(gpios)
    IO.inspect(job)
    {:ok, {gpios, job}}
  end

  @impl true
  def handle_info(:toggle, {gpios, job}) do
    GpioService.execute_actions(job, gpios)

    # Alternate.GpioService.execute_action("on", 12, data)
    # Alternate.GpioService.execute_action("on", 13, data)
    # Alternate.GpioService.execute_action("rising_edge", 19, data)
    # Circuits.GPIO.write(enable, 1)
    # Circuits.GPIO.write(dir, (value && 1) || 0)

    # Enum.each(0..50, fn _x ->
    # Circuits.GPIO.write(step, 0)
    # :timer.sleep(2)
    # Circuits.GPIO.write(step, 1)
    # :timer.sleep(2)
    # end)

    dispatch_job(job)
    {:noreply, {gpios, job}}
  end
end

defmodule Start do
  use Application

  def start(_type, _args) do
    IO.puts(~c"starting app...")
    Alternate.Supervisor.start_link()
     #{:normal}
    #{:ok, self()}
  end
end

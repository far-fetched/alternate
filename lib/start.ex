defmodule Start do
  use Application

  def start(_type, _args) do

    IO.puts 'starting app...'
    Alternate.Supervisor.start_link

  end
end

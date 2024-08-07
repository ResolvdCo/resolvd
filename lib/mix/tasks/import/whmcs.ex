defmodule Mix.Tasks.Import.Whmcs do
  @moduledoc """
  Update the local GraphQL Schema definition with your local repository.

      $ mix import.whmcs

  """

  use Mix.Task

  @impl Mix.Task
  def run(argv) do
    Mix.Task.run("app.start")
    Resolvd.Importers.WHMCS.import()
  end
end

defmodule Mix.Tasks.Solve do
  @moduledoc "Generate a new `Solution` module and input file for a given day."
  @shortdoc "Generate a solution files"

  use Mix.Task

  @impl Mix.Task
  def run([day]) do
    year = to_string(Date.utc_today().year)

    template_path = Path.join(["priv", "day_template.eex"])
    module_path = Path.join(["lib", "solutions", year, "day_#{day}.ex"])
    input_path = Path.join(["inputs", year, "day_#{day}.txt"])

    module_content = EEx.eval_file(template_path, year: year, day: day)

    File.write!(module_path, module_content)
    File.touch!(input_path)

    IO.puts("""
    Generated files:

      - #{module_path}
      - #{input_path}
    """)
  end
end

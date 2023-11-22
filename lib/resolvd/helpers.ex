defmodule Resolvd.Helpers do
  @doc """
  This escapes the default SQL escape character `\\`, and any wildcard characters (`%` and `_`)
  so they can be used in a `LIKE` statement.

  This may not be perfect and is based off of the Rails implementation and the MySQL docs.

  - https://apidock.com/rails/v4.2.1/ActiveRecord/Sanitization/ClassMethods/sanitize_sql_like
  - https://dev.mysql.com/doc/refman/8.0/en/string-comparison-functions.html#operator_like
  """
  def sanitize_sql_like(string, escape_character \\ "\\") do
    {:ok, pattern} =
      [escape_character, "%", "_"]
      |> Enum.map(&Regex.escape/1)
      |> Enum.join("|")
      |> Regex.compile()

    String.replace(string, pattern, fn x -> escape_character <> x end)
  end
end

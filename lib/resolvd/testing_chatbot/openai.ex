defmodule Resolvd.TestingChatbot.OpenAI do
  defp default_system_prompt(original_issue) do
    """
    You are pretending to be a customer emailing a support team about an issue.
    Your responses should be at least one paragraph long.
    Your original email to the support team was:

    #{original_issue}
    """
  end

  def call(original_issue, our_response, opts \\ []) do
    %{
      "model" => "gpt-3.5-turbo-0125",
      "messages" =>
        Enum.concat(
          [
            %{"role" => "system", "content" => default_system_prompt(original_issue)}
          ],
          [
            %{"role" => "user", "content" => our_response}
          ]
        ),
      "temperature" => 0.7
    }
    |> request(opts)
    |> parse_response()
  end

  defp parse_response({:ok, %Req.Response{body: body, status: 200}}) do
    messages =
      body
      |> Map.get("choices", [])
      |> Enum.reverse()

    case messages do
      [%{"message" => message} | _] -> message
      _ -> "{}"
    end
  end

  defp parse_response(error) do
    error
  end

  defp request(body, _opts) do
    Req.post("https://api.openai.com/v1/chat/completions", headers: headers(), json: body)
  end

  defp headers do
    [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{Application.get_env(:resolvd, :open_ai_api_key)}"}
    ]
  end
end

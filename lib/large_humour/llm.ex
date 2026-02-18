defmodule LargeHumour.LLM do
  alias LargeHumour.Jokes.Joke

  defp baseprompt do
    """
    Tell 10 jokes similar to this joke:

    """
  end

  defp prompt(joke) do
    [
      ReqLLM.Context.system("You are an expert on humour. "),
      ReqLLM.Context.user(baseprompt() <> joke)
    ]
  end

  def generate_similar(joke) do
    jokes_json =
      Zoi.object(jokes: Zoi.array(Zoi.string()))

    array_schema = jokes_json |> ReqLLM.Schema.to_json()

    ReqLLM.generate_object!(
      "openai:gpt-5-mini",
      # "groq:openai/gpt-oss-120b",
      prompt(joke),
      array_schema
    )
  end

  def generate_jokes(%Joke{} = joke) do
    %{"jokes" => jokes} = generate_similar(joke.text)

    jokes
    |> Enum.map(fn j ->
      %{
        source_joke_id: joke.id,
        code: "gpt-5.2_basic",
        # code: "gpt-oss-120b_basic",
        text: j,
        seed: false,
        llm_meta: %{}
      }
    end)
  end

  def generate_jokes!(%Joke{} = joke) do
    generate_jokes(joke)
    |> Enum.map(fn attrs -> LargeHumour.Jokes.create_joke(attrs) end)
  end
end

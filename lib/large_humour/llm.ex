defmodule LargeHumour.LLM do
  defstruct model: "groq:openai/gpt-oss-120b",
            system_prompt: "You are an expert on humour.",
            base_prompt: "Tell 10 jokes similar to this joke:"

  alias LargeHumour.Jokes.Joke
  alias LargeHumour.LLM

  def generate_similar(joke, %LLM{} = llm) do
    jokes_json =
      Zoi.object(jokes: Zoi.array(Zoi.string()))

    array_schema = jokes_json |> ReqLLM.Schema.to_json()

    prompt = [
      ReqLLM.Context.system(llm.system_prompt),
      ReqLLM.Context.user(llm.base_prompt <> joke)
    ]

    ReqLLM.generate_object!(
      llm.model,
      prompt,
      array_schema
    )
  end

  def generate_jokes(%Joke{} = joke, %LLM{} = llm) do
    %{"jokes" => jokes} = generate_similar(joke.text, llm)

    jokes
    |> Enum.map(fn j ->
      %{
        source_joke_id: joke.id,
        code: llm.model,
        # code: "gpt-oss-120b_basic",
        text: j,
        seed: false,
        llm_meta: llm
      }
    end)
  end

  def generate_jokes!(%Joke{} = joke, %LLM{} = llm) do
    generate_jokes(joke, llm)
    |> Enum.map(fn attrs -> LargeHumour.Jokes.create_joke(attrs) end)
  end
end

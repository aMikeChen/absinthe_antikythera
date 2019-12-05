use Croma

defmodule Absinthe.Antikythera.Controller do
  defmacro __using__(opts) do
    schema = Keyword.fetch!(opts, :schema)

    quote do
      use Antikythera.Controller

      alias Absinthe.Pipeline
      alias Antikythera.Conn

      @schema unquote(schema)

      defun query(%{request: %{body: body}} = conn :: v[Conn.t()]) :: Conn.t() do
        case execute(body) do
          {:ok, %{data: _} = result} ->
            Conn.json(conn, 200, result)

          {:ok, %{error: _} = result} ->
            Conn.json(conn, 200, result)

          {:ok, result} when is_list(result) ->
            Conn.json(conn, 200, result)

          {:input_error, msg} ->
            Conn.json(conn, 400, error_result(msg))

          {:error, error, _} when is_binary(error) ->
            Conn.json(conn, 500, error_result(error))
        end
      end

      defunp execute(%{"query" => query} = body) :: any do
        pipeline = build_pipeline(body)

        case Pipeline.run(query, pipeline) do
          {:ok, %{result: result}, _} ->
            {:ok, result}

          val ->
            val
        end
      end

      defunp build_pipeline(body :: v[map]) :: Pipeline.t() do
        options = [
          adapter: Absinthe.Adapter.LanguageConventions,
          context: %{},
          document_provider: {Absinthe.Plug.DocumentProvider.Default, []},
          document_provider_key: nil,
          params: body,
          pipeline: [],
          root_value: %{}
        ]

        Pipeline.for_document(@schema, options)
      end

      defunp error_result(message :: v[String.t()]) :: map do
        %{"errors" => [%{"message" => message}]}
      end
    end
  end
end

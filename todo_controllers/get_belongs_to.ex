defmodule AshJsonApi.Controllers.GetBelongsTo do
  def init(options) do
    # initialize options
    options
  end

  def call(%{path_params: %{"id" => id}} = conn, options) do
    resource = options[:resource]
    relationship = options[:relationship]
    related_resource = relationship.destination

    with {:ok, request} <- AshJsonApi.Request.from(conn, related_resource, :get_belongs_to),
         {:record, {:ok, record}} when not is_nil(record) <-
           {:record, Ash.Data.get_by_id(resource, id)},
         {:ok, related} <- Ash.Data.get_related(record, relationship),
         {:ok, found, includes} <- AshJsonApi.Includes.Includer.get_includes(related, request) do
      serialized = AshJsonApi.Serializer.serialize_one(request, found, includes)

      conn
      |> Plug.Conn.put_resp_content_type("application/vnd.api+json")
      |> Plug.Conn.send_resp(200, serialized)
    else
      {:error, error} ->
        raise "whups: #{inspect(error)}"

      {:record, {:error, error}} ->
        raise "whups: #{inspect(error)}"

      {:record, {:ok, nil}} ->
        conn
        # |> put_resp_content_type("text/plain")
        |> Plug.Conn.send_resp(404, "uh oh")
    end
    |> Plug.Conn.halt()
  end
end
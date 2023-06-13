defmodule ResolvdWeb.PolyInputs do
  use Phoenix.Component

  import Phoenix.HTML, only: [html_escape: 1]
  import Phoenix.HTML.Form, only: [hidden_inputs_for: 1, input_value: 2]

  @doc """
  Renders nested form inputs for associations or embeds.

  [INSERT LVATTRDOCS]

  ## Examples

  ```heex
  <.form
    :let={f}
    phx-change="change_name"
  >
    <.poly_inputs_for :let={f_nested} field={f[:nested]}>
      <.input type="text" field={f_nested[:name]} />
    </.poly_inputs_for>
  </.form>
  ```
  """
  @doc type: :component
  attr :field, Phoenix.HTML.FormField,
    required: true,
    doc: "A %Phoenix.HTML.Form{}/field name tuple, for example: {@form[:email]}."

  attr :id, :string,
    doc: """
    The id to be used in the form, defaults to the concatenation of the given
    field to the parent form id.
    """

  attr :as, :atom,
    doc: """
    The name to be used in the form, defaults to the concatenation of the given
    field to the parent form name.
    """

  attr :default, :any, doc: "The value to use if none is available."

  attr :prepend, :list,
    doc: """
    The values to prepend when rendering. This only applies if the field value
    is a list and no parameters were sent through the form.
    """

  attr :append, :list,
    doc: """
    The values to append when rendering. This only applies if the field value
    is a list and no parameters were sent through the form.
    """

  attr :skip_hidden, :boolean,
    default: false,
    doc: """
    Skip the automatic rendering of hidden fields to allow for more tight control
    over the generated markup.
    """

  slot :inner_block, required: true, doc: "The content rendered for each nested form."

  def poly_inputs_for(assigns) do
    %Phoenix.HTML.FormField{field: field_name, form: form} = assigns.field
    options = assigns |> Map.take([:id, :as, :default, :append, :prepend]) |> Keyword.new()

    options =
      form.options
      |> Keyword.take([:multipart])
      |> Keyword.merge(options)

    %schema{} = form.source.data
    type = get_polymorphic_type(form, schema, field_name)
    assigns = assign(assigns, :forms, to_form(form.source, form, field_name, type, options))

    ~H"""
    <%= for finner <- @forms do %>
      <%= unless @skip_hidden do %>
        <%= for {name, value_or_values} <- finner.hidden,
                name = name_for_value_or_values(finner, name, value_or_values),
                value <- List.wrap(value_or_values) do %>
          <input type="hidden" name={name} value={value} />
        <% end %>
      <% end %>
      <%= render_slot(@inner_block, finner) %>
    <% end %>
    """
  end

  defp to_form(%{action: parent_action} = source_changeset, form, field, type, options) do
    id = to_string(form.id <> "_#{field}")
    name = to_string(form.name <> "[#{field}]")

    params = Map.get(source_changeset.params || %{}, to_string(field), %{}) |> List.wrap()
    list_data = get_data(source_changeset, field, type) |> List.wrap()

    list_data
    |> Enum.with_index()
    |> Enum.map(fn {data, i} ->
      params = Enum.at(params, i) || %{}

      changeset =
        data
        |> Ecto.Changeset.change()
        |> apply_action(parent_action)

      errors = get_errors(changeset)

      changeset = %Ecto.Changeset{
        changeset
        | action: parent_action,
          params: params,
          errors: errors,
          valid?: errors == []
      }

      %Phoenix.HTML.Form{
        source: changeset,
        impl: Phoenix.HTML.FormData.Ecto.Changeset,
        id: id,
        index: if(length(list_data) > 1, do: i),
        name: name,
        errors: errors,
        data: data,
        params: params,
        hidden: [__type__: to_string(type)],
        options: options
      }
    end)
  end

  defp get_data(changeset, field, type) do
    struct = Ecto.Changeset.apply_changes(changeset)

    case Map.get(struct, field) do
      nil ->
        module = PolymorphicEmbed.get_polymorphic_module(struct.__struct__, field, type)
        if module, do: struct(module), else: []

      data ->
        data
    end
  end

  @doc """
  Returns the polymorphic type of the given field in the given form data.
  """
  defp get_polymorphic_type(%Phoenix.HTML.Form{} = form, schema, field) do
    case input_value(form, field) do
      %Ecto.Changeset{data: value} ->
        PolymorphicEmbed.get_polymorphic_type(schema, field, value)

      %_{} = value ->
        PolymorphicEmbed.get_polymorphic_type(schema, field, value)

      _ ->
        nil
    end
  end

  defp name_for_value_or_values(form, field, values) when is_list(values) do
    Phoenix.HTML.Form.input_name(form, field) <> "[]"
  end

  defp name_for_value_or_values(form, field, _value) do
    Phoenix.HTML.Form.input_name(form, field)
  end

  # If the parent changeset had no action, we need to remove the action
  # from children changeset so we ignore all errors accordingly.
  defp apply_action(changeset, nil), do: %{changeset | action: nil}
  defp apply_action(changeset, _action), do: changeset

  defp get_errors(%{action: nil}), do: []
  defp get_errors(%{action: :ignore}), do: []
  defp get_errors(%{errors: errors}), do: errors
end

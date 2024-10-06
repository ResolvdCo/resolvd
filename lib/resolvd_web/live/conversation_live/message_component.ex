defmodule ResolvdWeb.ConversationLive.MessageComponent do
  use ResolvdWeb, :live_component

  alias Resolvd.Conversations

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="message-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <%!-- <.input field={@form[:text_body]} type="textarea" label="Body" /> --%>
        <.live_file_input class="hidden" upload={@uploads.images} />
        <.input type="hidden" field={@form[:html_body]} id="trix-editor" phx-hook="Trix" />
        <div id="richtext" phx-update="ignore">
          <trix-editor
            input="trix-editor"
            class="trix-content prose max-w-none prose-pre:text-black min-h-36 border-none focus:border-none p-4 pt-0 sm:p-6 sm:pt-0 ring-none outline-none"
            placeholder="Write a reply!"
          >
          </trix-editor>
        </div>
        <:actions>
          <div class="p-4 sm:p-6">
            <.button phx-disable-with="Sending...">
              <.icon name="hero-paper-airplane" class="h-5 w-5 mr-2" /> Send Message
            </.button>
          </div>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{message: message} = assigns, socket) do
    changeset = Conversations.change_message(message)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)
     |> allow_upload(:images,
       progress: &handle_progress/3,
       auto_upload: true,
       accept: ~w(.jpg .jpeg .png)
     )}
  end

  @impl true
  def handle_event("validate", %{"message" => message_params}, socket) do
    changeset =
      socket.assigns.message
      |> Conversations.change_message(message_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :images, ref)}
  end

  def handle_event("save", %{"message" => message_params}, socket) do
    save_message(socket, socket.assigns.action, message_params)
  end

  # defp save_message(socket, :edit, message_params) do
  #   case Conversations.update_message(socket.assigns.message, message_params) do
  #     {:ok, message} ->
  #       notify_parent({:saved, message})

  #       {:noreply,
  #        socket
  #        |> put_flash(:info, "Message updated successfully")}

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       {:noreply, assign_form(socket, changeset)}
  #   end
  # end

  defp handle_progress(:images, entry, socket) do
    dbg(entry)

    if entry.done? do
      uploaded_file =
        consume_uploaded_entry(socket, entry, fn %{path: path} ->
          dest = Path.join([:code.priv_dir(:resolvd), "static", "uploads", Path.basename(path)])
          File.cp!(path, dest)
          {:ok, url(~p"/uploads/#{Path.basename(dest)}")}
        end)

      {:noreply,
       socket |> push_event("upload-completed", %{name: entry.client_name, url: uploaded_file})}
    else
      {:noreply,
       socket
       |> push_event("upload-progress", %{name: entry.client_name, progress: entry.progress})}
    end
  end

  defp save_message(socket, :new, message_params) do
    case Conversations.create_message(
           socket.assigns.conversation,
           socket.assigns.current_user,
           message_params
         ) do
      {{:ok, message}, conversation} ->
        # notify_parent({:saved, message, conversation})

        {:noreply, socket |> put_flash(:info, "Message created successfully")}

      {{:error, %Ecto.Changeset{} = changeset}, _conversation} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  # defp error_to_string(:too_large), do: "Too large"
  # defp error_to_string(:too_many_files), do: "You have selected too many files"
  # defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end

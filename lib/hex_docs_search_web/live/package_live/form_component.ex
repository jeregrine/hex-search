defmodule HexDocsSearchWeb.PackageLive.FormComponent do
  use HexDocsSearchWeb, :live_component

  alias HexDocsSearch.Hex

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage package records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="package-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:docs_html_url]} type="text" label="Docs html url" />
        <.input field={@form[:downloads_all]} type="number" label="Download all" />
        <.input field={@form[:downloads_day]} type="number" label="Downloads day" />
        <.input field={@form[:downloads_recent]} type="number" label="Downloads recent" />
        <.input field={@form[:downloads_week]} type="number" label="Downloads week" />
        <.input field={@form[:latest_docs_url]} type="text" label="Latest docs url" />
        <.input field={@form[:html_url]} type="text" label="Html url" />
        <.input field={@form[:latest_stable_version]} type="text" label="Latest stable version" />
        <.input field={@form[:meta]} type="text" label="Meta" />
        <.input field={@form[:search_items_json]} type="text" label="Search items json" />
        <.input field={@form[:sidebar_items_json]} type="text" label="Sidebar items json" />
        <.input field={@form[:last_pulled]} type="datetime-local" label="Last pulled" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Package</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{package: package} = assigns, socket) do
    changeset = Hex.change_package(package)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"package" => package_params}, socket) do
    changeset =
      socket.assigns.package
      |> Hex.change_package(package_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"package" => package_params}, socket) do
    save_package(socket, socket.assigns.action, package_params)
  end

  defp save_package(socket, :edit, package_params) do
    case Hex.update_package(socket.assigns.package, package_params) do
      {:ok, package} ->
        notify_parent({:saved, package})

        {:noreply,
         socket
         |> put_flash(:info, "Package updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_package(socket, :new, package_params) do
    case Hex.create_package(package_params) do
      {:ok, package} ->
        notify_parent({:saved, package})

        {:noreply,
         socket
         |> put_flash(:info, "Package created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end

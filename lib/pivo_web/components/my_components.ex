defmodule PivoWeb.MyComponents do
  @moduledoc false
  use Phoenix.Component
  use Gettext, backend: PivoWeb.Gettext

  import PivoWeb.CoreComponents

  alias Phoenix.LiveView.JS

  slot(:title)
  slot(:inner_block, required: true)

  slot :link, required: true do
    attr(:icon, :string)
    attr(:label, :string, required: true)
    attr(:navigate, :any, required: true)
  end

  def navbar(assigns) do
    ~H"""
    <nav class="border-b border-zinc-400 px-4 sm:px-6 lg:px-8">
      <div class="flex justify-between py-3 text-sm">
        {render_slot(@title)}
        <button
          id="show-navbar-button"
          phx-click={show_mobile_navbar()}
          class="inline-flex items-center"
        >
          <.icon name="hero-bars-3" class="h-8 w-8" />
        </button>
        <button
          id="hide-navbar-button"
          phx-click={hide_mobile_navbar()}
          class="hidden inline-flex items-center"
        >
          <.icon name="hero-bars-3" class="h-8 w-8" />
        </button>
        <div
          id="navbar-default"
          class="hidden absolute shadow-md z-20 top-[59px] right-0 dropdown border-b border-l border-zinc-400"
        >
          <ul class="bg-white dark:bg-gray-800 pl-4 p-2 pr-5 flex flex-col text-left">
            <li
              :for={{link, _i} <- Enum.with_index(@link)}
              class="border-zinc-300 border-b-2 last:border-b-0 py-4"
            >
              <.link navigate={link.navigate} class="flex items-center gap-x-2">
                <.icon :if={link.icon} name={link.icon || ""} class="h-6 w-6" />
                {link.label} <.icon name="hero-chevron-right ml-auto" class="h-6 w-6" />
              </.link>
            </li>
          </ul>
        </div>
      </div>
    </nav>
    """
  end

  def show_mobile_navbar(js \\ %JS{}) do
    js
    |> JS.show(
      to: "#navbar-default",
      transition: {"ease-in-out duration-300", "opacity-0", "opacity-100"}
    )
    |> JS.hide(to: "#show-navbar-button")
    |> JS.show(to: "#hide-navbar-button")
  end

  def hide_mobile_navbar(js \\ %JS{}) do
    js
    |> JS.hide(
      to: "#navbar-default",
      transition: {"ease-in-out duration-300", "opacity-100", "opacity-0"}
    )
    |> JS.show(to: "#show-navbar-button")
    |> JS.hide(to: "#hide-navbar-button")
  end

  @doc """
  Renders a modal.

  ## Examples

      <.modal id="confirm-modal">
        This is a modal.
      </.modal>

  JS commands may be passed to the `:on_cancel` to configure
  the closing/cancel event, for example:

      <.modal id="confirm" on_cancel={JS.navigate(~p"/posts")}>
        This is another modal.
      </.modal>

  """
  attr(:id, :string, required: true)
  attr(:show, :boolean, default: false)
  attr(:on_cancel, JS, default: %JS{})
  slot(:inner_block, required: true)

  def modal(assigns) do
    ~H"""
    <div
      id={@id}
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      data-cancel={JS.exec(@on_cancel, "phx-remove")}
      class="relative z-50 hidden"
    >
      <div
        id={"#{@id}-bg"}
        class="bg-zinc-50/90 dark:bg-gray-900/90 fixed inset-0 transition-opacity"
        aria-hidden="true"
      />
      <div
        class="fixed inset-0 overflow-y-auto"
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <div class="flex min-h-full items-center justify-center">
          <div class="w-full max-w-3xl p-4 sm:p-6 lg:py-8">
            <.focus_wrap
              id={"#{@id}-container"}
              phx-window-keydown={JS.exec("data-cancel", to: "##{@id}")}
              phx-key="escape"
              phx-click-away={JS.exec("data-cancel", to: "##{@id}")}
              class="border dark:border-zinc-500 shadow-zinc-700/10 ring-zinc-700/10 dark:shadow-zinc-10/10 dark:ring-zinc-10/10 relative hidden rounded-2xl bg-white dark:bg-gray-800 p-8 shadow-lg ring-1 transition"
            >
              <div class="absolute top-6 right-5">
                <button
                  phx-click={JS.exec("data-cancel", to: "##{@id}")}
                  type="button"
                  class="-m-3 flex-none p-3 opacity-20 hover:opacity-40"
                  aria-label={gettext("close")}
                >
                  <.icon name="hero-x-mark-solid" class="h-5 w-5" />
                </button>
              </div>
              <div id={"#{@id}-content"}>
                {render_slot(@inner_block)}
              </div>
            </.focus_wrap>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders a simple form.

  ## Examples

      <.simple_form for={@form} phx-change="validate" phx-submit="save">
        <.input field={@form[:email]} label="Email"/>
        <.input field={@form[:username]} label="Username" />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.simple_form>
  """
  attr :for, :any, required: true, doc: "the data structure for the form"
  attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"

  attr :rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target multipart),
    doc: "the arbitrary HTML attributes to apply to the form tag"

  slot :inner_block, required: true
  slot :actions, doc: "the slot for form actions, such as a submit button"

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <div class="mt-10 space-y-8">
        {render_slot(@inner_block, f)}
        <div :for={action <- @actions} class="mt-2 flex items-center justify-between gap-6">
          {render_slot(action, f)}
        </div>
      </div>
    </.form>
    """
  end

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.show(
      to: "##{id}-bg",
      time: 300,
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> show("##{id}-container")
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id}-content")
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
    )
    |> hide("##{id}-container")
    |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.pop_focus()
  end
end

defmodule PivoWeb.AboutLive do
  @moduledoc false
  use PivoWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-100 flex flex-col items-center p-4">
      <div class="w-full max-w-lg sm:max-w-xl bg-white shadow-lg rounded-2xl p-6 text-center">
        <p class="text-lg text-gray-700 mb-4">
          This page is dedicated to our favorite beer: <span class="font-semibold">Vinohradská 11</span>! 🍺
        </p>
        <p class="text-lg text-gray-700 mb-4">
          If you're a fan of crisp, perfectly balanced lagers, you're in the right place.
          We’re on a mission to help each other find where this legendary beer is available in Copenhagen. 🗺️✨
        </p>
        <p class="text-lg text-gray-700 mb-8">
          Whether you've spotted it in a cozy pub, a trendy bar, or a hidden gem, share your findings with the community.
          Together, we make sure no one misses out on a great beer of Vinohradská 11! 🍻
        </p>
        <.link
          href={~p"/"}
          class="bg-yellow-500 text-white px-6 py-3 rounded-lg text-lg font-semibold shadow-md hover:bg-yellow-600 transition"
        >
          Find Vinohradská 11 🍺
        </.link>
        <p class="text-lg text-gray-700 mt-8">
          Have suggestions or want to reach out? Feel free to email me at
          <a href="mailto:pivomorten@gmail.com" class="text-orange-500 font-semibold hover:underline">
            pivomorten@gmail.com
          </a>
          📧
        </p>
      </div>
    </div>
    """
  end
end

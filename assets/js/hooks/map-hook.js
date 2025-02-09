import mapboxgl from "mapbox-gl";

const MapHook = {
  mounted() {
    mapboxgl.accessToken = this.el.dataset.accessToken;

    const locations = JSON.parse(this.el.dataset.locations);

    const map = new mapboxgl.Map({
      container: this.el.id,
      zoom: 13,
      center: [12.547187368954477, 55.66598654676102] // [lng, lat]
    });


    for (const location of locations) {

      const html = `
        <div class="text-zinc-700">
          <h1 class="text-lg font-semibold">${location.name}</h1>
          <p class="text-lg">${'⭐'.repeat(location.rating)}</p>
          <p>${location.description}</p>
        </div>
      `;

      // Create a new marker.
      const marker = new mapboxgl.Marker()
        .setLngLat([location.lng, location.lat])
        .setPopup(new mapboxgl.Popup().setHTML(html))
        .addTo(map);

      marker.togglePopup(); // toggle popup open or closed
    }
  },
};

export default MapHook;

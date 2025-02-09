import mapboxgl from "mapbox-gl";

const MapHook = {
  mounted() {
    mapboxgl.accessToken = this.el.dataset.accessToken;

    const locations = JSON.parse(this.el.dataset.locations);

    const map = new mapboxgl.Map({
      container: this.el.id,
      zoom: 12,
      center: [
        12.569157292471003,
        55.67622541130143
      ]
    });

    // Add geolocate control to the map.
    const geolocate = map.addControl(
      new mapboxgl.GeolocateControl({
        positionOptions: {
          enableHighAccuracy: true
        },
        // When active the map will receive updates to the device's location as it changes.
        trackUserLocation: true,
        // Draw an arrow next to the location dot to indicate which direction the device is heading.
        showUserHeading: true
      })
    );

    // Add the control to the map.
    map.addControl(geolocate);
    map.on('load', () => {
        geolocate.trigger();
    });

    for (const location of locations) {
      const el = document.createElement('div');
      el.className = `bg-cover rounded-full w-8 h-8 border-2`;
      el.style.backgroundImage = `url(/images/${location.logo})`;
      el.classList.add(`${location.vino ? 'border-green-500' : 'border-red-500'}`);

      const html = `<div>
        <h1 class="font-semibold">${location.name}</h1>
      </div>`;

      // Create a new marker.
      const marker = new mapboxgl.Marker(el)
        .setLngLat([location.lng, location.lat])
        .setPopup(new mapboxgl.Popup({offset: 25}).setHTML(html))
        .addTo(map);

      //marker.togglePopup(); // toggle popup open or closed
    }
  },
};

export default MapHook;

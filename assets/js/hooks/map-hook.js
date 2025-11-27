import mapboxgl from "mapbox-gl";

const MapHook = {
  mounted() {
    mapboxgl.accessToken = this.el.dataset.accessToken;

    const locations = JSON.parse(this.el.dataset.locations);

    const darkMode = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;

    const map = new mapboxgl.Map({
      container: this.el.id,
      zoom: 11,
      style: darkMode ? 'mapbox://styles/mapbox/dark-v11' : 'mapbox://styles/mapbox/standard',
      center: [
        12.545828760633713,
        55.671543087513 
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
      el.className = `bg-cover rounded-full w-10 h-10`;
      el.style.backgroundImage = `url(/images/${location.logo})`;

      const div = document.createElement('div');
      div.className = 'absolute -inset-2 flex items-center justify-center opacity-80';
      const span = document.createElement('div');
      div.appendChild(span);
      if (location.vino) {
        span.className = 'hero-check-circle text-green-500 w-14 h-14';
      } else {
        span.className = 'hero-no-symbol text-red-500 w-14 h-14';
      }

      el.appendChild(div);

      const optionalCanningDate = location.canning_date ? `
        <div class="flex text-zinc-500 text-xs pt-2">
          Canned on: ${location.canning_date}
        </div>
      ` : '';

      const html = `<div>
        <div class="inline-flex pb-1 gap-1 items-center">
          <img src="/images/${location.vino ? 'beer.png' : 'no_beer.png'}" class="w-4 h-4 object-cover" />
          <h1 class="text-zinc-800 font-semibold">${location.name}</h1>
        </div>
        <div class="flex items-center gap-x-1 text-zinc-700">
          <p>${location.latest_update_comment ?? ""}</p>
        </div>
        ${optionalCanningDate}
        <div class="flex text-zinc-500 text-xs pt-2">
          ${location.latest_update} 
        </div>
        <div class="flex text-orange-700 text-xs pt-3 justify-end">
          <a href='/beer_status/new?beer_shop_id=${location.id}'>
            <span>Report Vino</span>
          </a>
        </div>
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

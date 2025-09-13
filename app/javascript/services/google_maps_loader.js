export default class GoogleMapsLoader {
  constructor(apiKey, libraries = ["places"]) {
    this.apiKey = apiKey;
    this.libraries = libraries;
    this.loaded = false;
  }

  async load() {
    console.log("Loading Google Maps API");

    if (this.loaded || (window.google && window.google.maps)) return;

    await new Promise((resolve, reject) => {
      const script = document.createElement("script");
      script.src = `https://maps.googleapis.com/maps/api/js?key=${
        this.apiKey
      }&libraries=${this.libraries.join(",")}`;
      script.async = true;
      script.defer = true;
      script.onload = resolve;
      script.onerror = () =>
        reject(new Error("Google Maps API failed to load"));
      document.head.appendChild(script);
    });

    this.loaded = true;
  }
}

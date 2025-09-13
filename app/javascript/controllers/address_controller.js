import { Controller } from "@hotwired/stimulus";
import GoogleMapsLoader from "../services/google_maps_loader";
import AddressParser from "../services/address_parser";

export default class extends Controller {
  static targets = ["input", "postal_code"];

  async connect() {
    const apiKey = document.querySelector(
      "meta[name='google-maps-api-key']"
    ).content;
    this.loader = new GoogleMapsLoader(apiKey);
    this.autocomplete = null;

    await this.initGoogleMaps();
  }

  async initGoogleMaps() {
    await this.loader.load();

    if (!this.autocomplete) {
      this.autocomplete = new google.maps.places.Autocomplete(
        this.inputTarget,
        {
          componentRestrictions: { country: ["us", "ca"] },
          types: ["address"],
          fields: ["address_components", "geometry", "formatted_address"],
        }
      );

      this.autocomplete.addListener("place_changed", () =>
        this.placeSelected()
      );
    }
  }

  placeSelected() {
    const place = this.autocomplete.getPlace();
    this.postal_codeTarget.value = AddressParser.getComponent(
      place,
      "postal_code"
    );

    // this.inputTarget.value = "";
  }
}

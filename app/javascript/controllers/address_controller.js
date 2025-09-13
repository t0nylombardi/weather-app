import { Controller } from "@hotwired/stimulus";
import GoogleMapsLoader from "../services/google_maps_loader";
import AddressParser from "../services/address_parser";

export default class extends Controller {
  static targets = ["input", "postal_code"];

  connect() {
    console.log("AddressController connected");
    const apiKey = document.querySelector(
      "meta[name='google-maps-api-key']"
    ).content;
    this.loader = new GoogleMapsLoader(apiKey);
    this.autocomplete = null;
  }

  async initGoogleMaps() {
    console.log("Initializing Google");
    await this.loader.load();

    if (!this.autocomplete) {
      this.autocomplete = new google.maps.places.Autocomplete(
        this.inputTarget,
        {
          componentRestrictions: { country: ["us", "ca"] },
          types: ["address"],
          fields: ["address_components"],
        }
      );

      this.autocomplete.addListener("place_changed", () =>
        this.placeSelected()
      );
    }
  }

  placeSelected() {
    console.log("Place selected");
    const place = this.autocomplete.getPlace();
    this.postal_codeTarget.value = AddressParser.getComponent(
      place,
      "postal_code"
    );
  }
}

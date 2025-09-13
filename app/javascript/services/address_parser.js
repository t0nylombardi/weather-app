export default class AddressParser {
  static getComponent(place, type) {
    console.log("Parsing address component:", type);

    if (!place.address_components) return "";

    for (const part of place.address_components) {
      if (part.types.includes(type)) {
        return part.long_name;
      }
    }

    return "";
  }
}

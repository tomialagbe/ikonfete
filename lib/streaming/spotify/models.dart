enum SpotifyProduct { Free, Premium }

class SpotifyUser {
  String id;
  String displayName;
  String email;
  SpotifyProduct product;

  SpotifyUser.fromMap(Map map) {
    this
      ..id = map["id"]
      ..displayName = map["display_name"]
      ..email = map["email"]
      ..product = _getProduct(map["product"]);
  }

  SpotifyProduct _getProduct(String p) {
    switch (p) {
      case "free":
      case "open":
        return SpotifyProduct.Free;
      case "premium":
      default:
        return SpotifyProduct.Premium;
    }
  }
}

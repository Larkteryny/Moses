import "package:geolocator/geolocator.dart";

Future<Map<String, double>> getGPSLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // Obtain position
  Position position = await Geolocator.getCurrentPosition();
  return {"latitude": position.latitude, "longitude": position.longitude};
}
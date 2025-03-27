import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        openAppSettings(); 
        return false;
        }
    }
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  static Future<Position?> getCurrentLocation() async {
    bool hasPermission = await requestPermission();
    if (!hasPermission) return null;
    return await Geolocator.getCurrentPosition();
  }
}

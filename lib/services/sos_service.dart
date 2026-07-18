import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/emergency_contact.dart';

/// Handles the SOS flow: get current location, build an alert message,
/// and hand off to the phone's SMS app for each emergency contact.
class SosService {
  /// Requests location permission if needed and returns the current position.
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied.');
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  String buildAlertMessage(Position position) {
    final mapsLink =
        'https://maps.google.com/?q=${position.latitude},${position.longitude}';
    return 'EMERGENCY! I need help. My current location: $mapsLink';
  }

  /// Opens the SMS app pre-filled with the alert message for one contact.
  /// (User taps send — Flutter apps can't silently send SMS without a
  /// native platform channel + special permissions, so this keeps it
  /// simple and reliable for V1.)
  Future<void> sendSmsAlert(String phone, String message) async {
    final uri = Uri(
      scheme: 'sms',
      path: phone,
      queryParameters: {'body': message},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('Could not open SMS app for $phone');
    }
  }

  /// Sends alerts to all contacts, one after another.
  Future<void> triggerSosToAllContacts(
    List<EmergencyContact> contacts,
  ) async {
    final position = await getCurrentLocation();
    final message = buildAlertMessage(position);
    for (final contact in contacts) {
      await sendSmsAlert(contact.phone, message);
    }
  }

  /// Dials a number directly (used for the "Call Police" quick action).
  Future<void> callNumber(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('Could not place call to $number');
    }
  }
}

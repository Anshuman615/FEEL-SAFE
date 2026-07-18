import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/emergency_contact.dart';

/// Handles saving/loading up to 5 emergency contacts on-device.
class ContactsStorageService {
  static const _key = 'emergency_contacts';
  static const maxContacts = 5;

  Future<List<EmergencyContact>> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded.map((e) => EmergencyContact.fromJson(e)).toList();
  }

  Future<bool> saveContacts(List<EmergencyContact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(contacts.map((c) => c.toJson()).toList());
    return prefs.setString(_key, encoded);
  }

  Future<List<EmergencyContact>> addContact(
    List<EmergencyContact> current,
    EmergencyContact newContact,
  ) async {
    if (current.length >= maxContacts) {
      throw Exception('Maximum $maxContacts contacts allowed');
    }
    final updated = [...current, newContact];
    await saveContacts(updated);
    return updated;
  }

  Future<List<EmergencyContact>> removeContact(
    List<EmergencyContact> current,
    int index,
  ) async {
    final updated = [...current]..removeAt(index);
    await saveContacts(updated);
    return updated;
  }
}

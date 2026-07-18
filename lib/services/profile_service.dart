import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class ProfileService {
  static const _key = 'user_profile';

  Future<UserProfile?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    return UserProfile.fromJson(jsonDecode(raw));
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(profile.toJson()));
  }

  /// Picks the most relevant Indian emergency helpline for this profile.
  /// Age takes priority (child/senior helplines are purpose-built),
  /// then gender, falling back to the general emergency number.
  ({String label, String number}) helplineFor(UserProfile profile) {
    if (profile.ageGroup == AgeGroup.child) {
      return (label: 'Child Helpline', number: '1098');
    }
    if (profile.ageGroup == AgeGroup.senior) {
      return (label: 'Senior Citizen Helpline', number: '14567');
    }
    if (profile.gender == Gender.female) {
      return (label: 'Women Helpline', number: '1091');
    }
    return (label: 'Emergency Helpline', number: '112');
  }
}

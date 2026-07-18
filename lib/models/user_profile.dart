enum Gender { male, female, other }

enum AgeGroup { child, adult, senior }

class UserProfile {
  final String name;
  final Gender gender;
  final AgeGroup ageGroup;
  final String phone;
  final String dob;
  final String address;

  UserProfile({
    required this.name,
    required this.gender,
    required this.ageGroup,
    this.phone = '',
    this.dob = '',
    this.address = '',
  });

  UserProfile copyWith({
    String? name,
    Gender? gender,
    AgeGroup? ageGroup,
    String? phone,
    String? dob,
    String? address,
  }) {
    return UserProfile(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      ageGroup: ageGroup ?? this.ageGroup,
      phone: phone ?? this.phone,
      dob: dob ?? this.dob,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'gender': gender.name,
        'ageGroup': ageGroup.name,
        'phone': phone,
        'dob': dob,
        'address': address,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      gender: Gender.values.byName(json['gender'] as String),
      ageGroup: AgeGroup.values.byName(json['ageGroup'] as String),
      phone: json['phone'] as String? ?? '',
      dob: json['dob'] as String? ?? '',
      address: json['address'] as String? ?? '',
    );
  }
}

import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileService = ProfileService();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  late TextEditingController _addressController;
  UserProfile? _profile;
  Gender? _gender;
  AgeGroup? _ageGroup;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _dobController = TextEditingController();
    _addressController = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    final profile = await _profileService.loadProfile();
    if (profile != null) {
      _nameController.text = profile.name;
      _phoneController.text = profile.phone;
      _dobController.text = profile.dob;
      _addressController.text = profile.address;
      _gender = profile.gender;
      _ageGroup = profile.ageGroup;
    }
    setState(() {
      _profile = profile;
      _loading = false;
    });
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dobController.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty ||
        _gender == null ||
        _ageGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Naam aur gender/age group zaroori hai.')),
      );
      return;
    }
    final updated = (_profile ??
            UserProfile(
                name: '', gender: Gender.other, ageGroup: AgeGroup.adult))
        .copyWith(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      dob: _dobController.text.trim(),
      address: _addressController.text.trim(),
      gender: _gender,
      ageGroup: _ageGroup,
    );
    await _profileService.saveProfile(updated);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile update ho gaya.')),
    );
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Name',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: _fieldDecoration(),
            ),
            const SizedBox(height: 18),
            const Text('Phone Number',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: _fieldDecoration(hint: 'Add your phone number'),
            ),
            const SizedBox(height: 18),
            const Text('Date of Birth',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _dobController,
              readOnly: true,
              onTap: _pickDob,
              decoration: _fieldDecoration(hint: 'Tap to select date').copyWith(
                suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
              ),
            ),
            const SizedBox(height: 18),
            const Text('Address',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _addressController,
              maxLines: 2,
              decoration: _fieldDecoration(hint: 'Add your address'),
            ),
            const SizedBox(height: 18),
            const Text('Gender',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _chip('Male', _gender == Gender.male,
                    () => setState(() => _gender = Gender.male)),
                _chip('Female', _gender == Gender.female,
                    () => setState(() => _gender = Gender.female)),
                _chip('Other', _gender == Gender.other,
                    () => setState(() => _gender = Gender.other)),
              ],
            ),
            const SizedBox(height: 18),
            const Text('Age group',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _chip('Child (under 18)', _ageGroup == AgeGroup.child,
                    () => setState(() => _ageGroup = AgeGroup.child)),
                _chip('Adult', _ageGroup == AgeGroup.adult,
                    () => setState(() => _ageGroup = AgeGroup.adult)),
                _chip('Senior (60+)', _ageGroup == AgeGroup.senior,
                    () => setState(() => _ageGroup = AgeGroup.senior)),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Save Changes',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.softShadow),
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      backgroundColor: AppColors.white,
      selectedColor: AppColors.iosBlue.withOpacity(0.12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
            color: selected ? AppColors.iosBlue : AppColors.softShadow),
      ),
      labelStyle: TextStyle(
        color: selected ? AppColors.iosBlue : AppColors.almostBlack,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
    );
  }
}

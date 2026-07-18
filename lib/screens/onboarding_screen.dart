import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _profileService = ProfileService();
  final _nameController = TextEditingController();
  Gender? _gender;
  AgeGroup? _ageGroup;

  Future<void> _continue() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _gender == null || _ageGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Sab fields bharo taaki sahi helpline set ho sake.')),
      );
      return;
    }
    final profile =
        UserProfile(name: name, gender: _gender!, ageGroup: _ageGroup!);
    await _profileService.saveProfile(profile);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.iosBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_outlined,
                    size: 32, color: AppColors.iosBlue),
              ),
              const SizedBox(height: 20),
              Text('Welcome to Feel Safe',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              const Text(
                'Ek safety app jo har umar aur har gender ke liye bani hai — bachchon se lekar buzurgo tak.',
                style: TextStyle(color: AppColors.almostBlack, height: 1.4),
              ),
              const SizedBox(height: 32),
              const Text('Your name',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.softShadow),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.softShadow),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.iosBlue, width: 1.5),
                  ),
                  hintText: 'Enter your name',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 28),
              const Text('You are',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _ChoiceChip(
                    label: 'Male',
                    selected: _gender == Gender.male,
                    onTap: () => setState(() => _gender = Gender.male),
                  ),
                  _ChoiceChip(
                    label: 'Female',
                    selected: _gender == Gender.female,
                    onTap: () => setState(() => _gender = Gender.female),
                  ),
                  _ChoiceChip(
                    label: 'Other',
                    selected: _gender == Gender.other,
                    onTap: () => setState(() => _gender = Gender.other),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const Text('Age group',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _ChoiceChip(
                    label: 'Child (under 18)',
                    selected: _ageGroup == AgeGroup.child,
                    onTap: () => setState(() => _ageGroup = AgeGroup.child),
                  ),
                  _ChoiceChip(
                    label: 'Adult',
                    selected: _ageGroup == AgeGroup.adult,
                    onTap: () => setState(() => _ageGroup = AgeGroup.adult),
                  ),
                  _ChoiceChip(
                    label: 'Senior (60+)',
                    selected: _ageGroup == AgeGroup.senior,
                    onTap: () => setState(() => _ageGroup = AgeGroup.senior),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _continue,
                  child: const Text('Continue',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
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

import 'package:flutter/material.dart';
import '../models/emergency_contact.dart';
import '../models/user_profile.dart';
import '../services/contacts_service.dart';
import '../services/profile_service.dart';
import '../services/sos_service.dart';
import '../theme/app_theme.dart';
import '../widgets/sos_button.dart';
import 'contacts_screen.dart';
import 'fake_call_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _sosService = SosService();
  final _contactsStorage = ContactsStorageService();
  final _profileService = ProfileService();
  List<EmergencyContact> _contacts = [];
  UserProfile? _profile;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _loadProfile();
  }

  Future<void> _loadContacts() async {
    final contacts = await _contactsStorage.loadContacts();
    setState(() => _contacts = contacts);
  }

  Future<void> _loadProfile() async {
    final profile = await _profileService.loadProfile();
    setState(() => _profile = profile);
  }

  Future<void> _handleSos() async {
    if (_contacts.isEmpty) {
      _showSnack('Pehle emergency contacts add karo, phir SOS use hoga.');
      return;
    }
    setState(() => _isSending = true);
    try {
      await _sosService.triggerSosToAllContacts(_contacts);
      _showSnack('Alert bhej diya ${_contacts.length} contacts ko.');
    } catch (e) {
      _showSnack('SOS fail ho gaya: $e');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.shield_outlined, color: AppColors.iosBlue, size: 20),
            SizedBox(width: 8),
            Text('Feel Safe', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Profile',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
              _loadProfile();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              if (_profile != null)
                Text(
                  'Hi ${_profile!.name}, stay safe',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              const SizedBox(height: 8),
              Text(
                'Long-press for 3 seconds to send an SOS alert',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 36),
              _isSending
                  ? const Padding(
                      padding: EdgeInsets.all(60),
                      child: CircularProgressIndicator(color: AppColors.sosRed),
                    )
                  : SosButton(onTriggered: _handleSos),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.contacts,
                      label: 'Emergency\nContacts',
                      color: AppColors.iosBlue,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ContactsScreen(),
                          ),
                        );
                        _loadContacts();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.call,
                      label: 'Fake\nCall',
                      color: AppColors.warmOrange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FakeCallScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Builder(builder: (context) {
                final helpline = _profile != null
                    ? _profileService.helplineFor(_profile!)
                    : (label: 'Emergency Helpline', number: '112');
                return _QuickActionCard(
                  icon: Icons.local_police,
                  label: 'Call ${helpline.label} (${helpline.number})',
                  color: AppColors.sosRed,
                  fullWidth: true,
                  onTap: () => _sosService.callNumber(helpline.number),
                );
              }),
              const SizedBox(height: 24),
              Text(
                '${_contacts.length}/5 emergency contacts saved',
                style:
                    const TextStyle(color: AppColors.softShadow, fontSize: 12),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool fullWidth;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
              color: AppColors.softShadow.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            child: fullWidth
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: color, size: 26),
                      const SizedBox(width: 12),
                      Text(label,
                          style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                    ],
                  )
                : Column(
                    children: [
                      Icon(icon, color: color, size: 26),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

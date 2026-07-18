import 'package:flutter/material.dart';
import '../models/emergency_contact.dart';
import '../services/contacts_service.dart';
import '../theme/app_theme.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _storage = ContactsStorageService();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  List<EmergencyContact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final contacts = await _storage.loadContacts();
    setState(() => _contacts = contacts);
  }

  Future<void> _addContact() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      _showSnack('Naam aur number dono bharo.');
      return;
    }
    try {
      final updated = await _storage.addContact(
        _contacts,
        EmergencyContact(name: name, phone: phone),
      );
      setState(() => _contacts = updated);
      _nameController.clear();
      _phoneController.clear();
    } catch (e) {
      _showSnack('$e');
    }
  }

  Future<void> _removeContact(int index) async {
    final updated = await _storage.removeContact(_contacts, index);
    setState(() => _contacts = updated);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canAddMore = _contacts.length < ContactsStorageService.maxContacts;

    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Contacts')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (canAddMore) ...[
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _addContact,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Add Contact',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ] else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.warmOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Maximum 5 contacts reached. Remove one to add a new one.',
                  style: TextStyle(color: AppColors.almostBlack, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 24),
            Expanded(
              child: _contacts.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.people_outline,
                            size: 40, color: AppColors.softShadow),
                        SizedBox(height: 8),
                        Text('Koi contact save nahi hai abhi.',
                            style: TextStyle(color: AppColors.softShadow)),
                      ],
                    )
                  : ListView.separated(
                      itemCount: _contacts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final contact = _contacts[index];
                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: AppColors.iosBlue,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(contact.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(contact.phone),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: AppColors.sosRed),
                              onPressed: () => _removeContact(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:ammas_kitchen/config/app_config.dart';
import 'package:ammas_kitchen/services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _reminderDays = 7;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final days = await NotificationService.instance.getGlobalReminderDays();
    if (mounted) {
      setState(() {
        _reminderDays = days;
        _loading = false;
      });
    }
  }

  Future<void> _updateReminderDays(int days) async {
    setState(() => _reminderDays = days);
    await NotificationService.instance.setGlobalReminderDays(days);
    // Reschedule all notifications with the new default
    await NotificationService.instance.rescheduleAllNotifications();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reminders updated to ${reminderOptions[days]}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildSection(
                  title: 'Notifications',
                  icon: Icons.notifications_outlined,
                  children: [
                    ListTile(
                      title: const Text('Default Reminder'),
                      subtitle: Text(
                        reminderOptions[_reminderDays] ?? '$_reminderDays days before',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _showReminderPicker,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Items without a custom reminder will use this default. '
                        'You can also set reminders per item when adding them.',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
                const SizedBox(height: 8),
                _buildSection(
                  title: 'About',
                  icon: Icons.info_outline,
                  children: [
                    ListTile(
                      title: const Text("Amma's Kitchen"),
                      subtitle: Text('Version ${AppConfig.currentVersion}'),
                      leading: const Text('🍳', style: TextStyle(fontSize: 28)),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Made with love for Amma. Never waste food again!',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  void _showReminderPicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Remind me before expiry',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ...reminderOptions.entries.map((entry) => ListTile(
                  leading: Icon(
                    entry.key == _reminderDays
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: entry.key == _reminderDays
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  title: Text(entry.value),
                  onTap: () {
                    Navigator.pop(ctx);
                    _updateReminderDays(entry.key);
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

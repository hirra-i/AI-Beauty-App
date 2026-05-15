import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import '../services/user_data_service.dart';
import '../ui/widgets.dart';

class PersonalisedGuidancePermissionsScreen extends StatefulWidget {
  const PersonalisedGuidancePermissionsScreen({super.key});

  @override
  State<PersonalisedGuidancePermissionsScreen> createState() => _State();
}

class _State extends State<PersonalisedGuidancePermissionsScreen> {
  PermissionStatus _cam = PermissionStatus.denied;
  PermissionStatus _photos = PermissionStatus.denied;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final cam = await Permission.camera.status;
    final photos = await Permission.photos.status;
    if (!mounted) return;
    setState(() {
      _cam = cam;
      _photos = photos;
    });
  }

  bool get _allGranted => _cam.isGranted && _photos.isGranted;

  Future<void> _requestCam() async {
    final res = await Permission.camera.request();
    if (res.isPermanentlyDenied) _settingsDialog();
    await _refresh();
  }

  Future<void> _requestPhotos() async {
    final res = await Permission.photos.request();
    if (res.isPermanentlyDenied) _settingsDialog();
    await _refresh();
  }

  void _settingsDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Permission needed'),
        content: const Text('Enable access in Settings to use personalised guidance.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Not now')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              AppSettings.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _continue() async {
    setState(() => _saving = true);
    await UserDataService().setAiPermissionsPromptCompleted();
    if (!mounted) return;
    setState(() => _saving = false);

    Navigator.pushReplacementNamed(context, '/aiScan');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personalised guidance')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppSectionTitle(
              title: 'Enable camera & photos',
              subtitle:
                  'Used to analyse undertone for personalised guidance. Photos are processed on-device and not stored.',
            ),
            const SizedBox(height: 16),

            InfoCard(
              child: Column(
                children: [
                  _row(
                    title: 'Camera',
                    subtitle: 'Take a photo in natural light',
                    granted: _cam.isGranted,
                    onTap: _requestCam,
                  ),
                  const Divider(height: 22),
                  _row(
                    title: 'Photo library',
                    subtitle: 'Choose a photo you already have',
                    granted: _photos.isGranted,
                    onTap: _requestPhotos,
                  ),
                ],
              ),
            ),

            const Spacer(),
            SecondaryButton(
              text: 'Not now',
              onPressed: () async {
                await UserDataService().setAiPermissionsPromptCompleted();
                if (!context.mounted) return;
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              text: 'Continue',
              onPressed: _allGranted ? _continue : null,
              loading: _saving,
            ),
          ],
        ),
      ),
    );
  }

  Widget _row({
    required String title,
    required String subtitle,
    required bool granted,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: granted ? null : onTap,
      child: Row(
        children: [
          Icon(granted ? Icons.check_circle : Icons.lock_outline),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
          ),
          if (!granted) const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
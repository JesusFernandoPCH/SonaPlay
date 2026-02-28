import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SonaPlay/core/providers/permission_provider.dart';
import 'package:SonaPlay/core/services/permission_service.dart';

/// Screen shown when audio permission is not granted
class PermissionScreen extends ConsumerWidget {
  const PermissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionService = ref.watch(permissionServiceProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 150,
                  height: 150,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Acceso a tu música',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'SonaPlay necesita acceso a tus archivos de audio para reproducir tu música local.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () async {
                  final granted = await permissionService
                      .requestAudioPermission();
                  if (granted) {
                    // Permission granted, refresh app state
                    ref.invalidate(audioPermissionProvider);
                  } else {
                    // Check if permanently denied
                    final permanentlyDenied = await permissionService
                        .isAudioPermissionPermanentlyDenied();

                    if (permanentlyDenied && context.mounted) {
                      _showSettingsDialog(context, permissionService);
                    }
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  child: Text('Permitir acceso'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context, PermissionService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permiso denegado'),
        content: const Text(
          'Has denegado el permiso de acceso a archivos de audio. '
          'Para usar SonaPlay, debes habilitar este permiso en la configuración de la app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              service.openSettings();
              Navigator.pop(context);
            },
            child: const Text('Abrir configuración'),
          ),
        ],
      ),
    );
  }
}

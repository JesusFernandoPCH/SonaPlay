import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SonaPlay/core/theme/app_theme.dart';
import 'package:SonaPlay/core/providers/permission_provider.dart';
import 'package:SonaPlay/core/presentation/screens/permission_screen.dart';
import 'package:SonaPlay/features/library/presentation/screens/library_screen.dart';

/// Main app widget
class SonaPlayApp extends StatelessWidget {
  const SonaPlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SonaPlay',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      // Home
      home: const _PermissionGate(),
    );
  }
}

/// Gate that checks permissions before showing main app
class _PermissionGate extends ConsumerWidget {
  const _PermissionGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPermission = ref.watch(audioPermissionProvider);

    return hasPermission.when(
      data: (granted) {
        if (granted) {
          return const LibraryScreen();
        } else {
          return const PermissionScreen();
        }
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) =>
          Scaffold(body: Center(child: Text('Error checking permissions'))),
    );
  }
}

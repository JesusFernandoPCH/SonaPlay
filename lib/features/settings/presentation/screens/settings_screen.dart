import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SonaPlay/core/constants/app_colors.dart';
import 'package:SonaPlay/core/presentation/widgets/glass_container.dart';
import 'package:SonaPlay/core/presentation/widgets/vibrant_background.dart';
import 'package:SonaPlay/features/player/presentation/providers/palette_provider.dart';
import './hidden_songs_screen.dart';
import './recently_deleted_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkBlue,
      body: Stack(
        children: [
          // Dynamic Background Gradient
          VibrantBackground(accentColor: ref.watch(dominantColorProvider)),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    children: [
                      const SizedBox(height: 12),
                      _buildSettingsSection(context),
                      const SizedBox(height: 48),
                      _buildFooter(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Ajustes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          _buildActionSetting(
            title: 'Archivos Ocultos',
            subtitle: 'Gestiona la música que has decidido ocultar',
            icon: Icons.visibility_off_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HiddenSongsScreen(),
                ),
              );
            },
          ),
          const Divider(color: Colors.white10),
          _buildActionSetting(
            title: 'Eliminado Recientemente',
            subtitle: 'Recupera canciones eliminadas por error',
            icon: Icons.delete_outline_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecentlyDeletedScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionSetting({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primaryBlue, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white54, fontSize: 13),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white30),
      onTap: onTap,
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          const Text(
            'SonaPlay v1.0.0',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Built with elegance and performance',
            style: TextStyle(color: Colors.white24, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

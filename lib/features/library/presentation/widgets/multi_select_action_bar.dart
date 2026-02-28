import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:SonaPlay/core/constants/app_colors.dart';
import 'package:SonaPlay/core/presentation/widgets/glass_container.dart';
import 'package:SonaPlay/features/library/presentation/providers/deleted_songs_provider.dart';
import 'package:SonaPlay/features/library/presentation/providers/hidden_songs_provider.dart';
import 'package:SonaPlay/features/library/presentation/providers/library_provider.dart';
import 'package:SonaPlay/features/library/presentation/providers/playlists_provider.dart';
import 'package:SonaPlay/features/library/presentation/providers/selection_provider.dart';
import 'package:SonaPlay/features/player/presentation/providers/audio_provider.dart';

/// Premium header for selection mode
class MultiSelectHeader extends ConsumerWidget implements PreferredSizeWidget {
  const MultiSelectHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionState = ref.watch(selectionControllerProvider);
    final selectedCount = selectionState.selectedCount;

    return SafeArea(
      child: Container(
        height: kToolbarHeight + 20,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                ref
                    .read(selectionControllerProvider.notifier)
                    .exitSelectionMode();
              },
            ),
            const SizedBox(width: 8),
            Text(
              '$selectedCount seleccionado',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Premium bottom action bar for selection mode
class MultiSelectBottomBar extends ConsumerWidget {
  const MultiSelectBottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassContainer(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      opacity: 0.15,
      showBorder: true,
      borderColor: Colors.white.withValues(alpha: 0.08),
      padding: const EdgeInsets.only(top: 20, bottom: 40, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ActionButton(
            icon: Icons.playlist_add,
            label: 'Agregar a',
            onTap: () => _addToPlaylistSelected(context, ref),
          ),
          _ActionButton(
            icon: Icons.queue_music,
            label: 'Reproducir a\ncontinuación',
            onTap: () => _playNextSelected(context, ref),
          ),
          _ActionButton(
            icon: Icons.shortcut,
            label: 'Compartir',
            onTap: () => _shareSelected(context, ref),
          ),
          _ActionButton(
            icon: Icons.visibility_off,
            label: 'Ocultar',
            onTap: () => _hideSelected(context, ref),
          ),
          _ActionButton(
            icon: Icons.delete,
            label: 'Borrar',
            onTap: () => _showDeleteConfirmation(context, ref),
            color: Colors.redAccent,
          ),
        ],
      ),
    );
  }

  // --- Logic ported from old MultiSelectActionBar ---

  Future<void> _playNextSelected(BuildContext context, WidgetRef ref) async {
    final selectionState = ref.read(selectionControllerProvider);
    final allSongs = ref.read(visibleSongsProvider).value ?? [];
    final selectedSongs = selectionState.getSelectedSongs(allSongs);

    final controller = ref.read(audioControllerProvider);
    for (final song in selectedSongs) {
      await controller.playNext(song);
    }

    ref.read(selectionControllerProvider.notifier).exitSelectionMode();
  }

  Future<void> _shareSelected(BuildContext context, WidgetRef ref) async {
    final selectionState = ref.read(selectionControllerProvider);
    final allSongs = ref.read(visibleSongsProvider).value ?? [];
    final selectedSongs = selectionState.getSelectedSongs(allSongs);

    final files = selectedSongs.map((s) => XFile(s.filePath)).toList();
    ref.read(selectionControllerProvider.notifier).exitSelectionMode();

    try {
      await Share.shareXFiles(files);
    } catch (_) {}
  }

  Future<void> _hideSelected(BuildContext context, WidgetRef ref) async {
    final selectionState = ref.read(selectionControllerProvider);
    final selectedIds = selectionState.selectedSongIds;
    final hiddenController = ref.read(hiddenSongsControllerProvider);

    for (final songId in selectedIds) {
      await hiddenController.hideSong(songId);
    }

    ref.read(selectionControllerProvider.notifier).exitSelectionMode();
  }

  Future<void> _deleteSelected(BuildContext context, WidgetRef ref) async {
    final selectionState = ref.read(selectionControllerProvider);
    final selectedIds = selectionState.selectedSongIds;
    final deletedController = ref.read(deletedSongsControllerProvider);

    for (final songId in selectedIds) {
      await deletedController.softDeleteSong(songId);
    }

    ref.read(selectionControllerProvider.notifier).exitSelectionMode();
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B2A),
        title: const Text(
          'Eliminar canciones',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Estás seguro de que quieres mover estas canciones a la papelera?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSelected(context, ref);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _addToPlaylistSelected(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final playlistsAsync = ref.read(playlistsStreamProvider);

    playlistsAsync.whenData((playlists) {
      if (playlists.isEmpty) return;

      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF101622),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Agregar a Playlist',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(color: Colors.white10),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.playlist_add,
                        color: AppColors.primaryBlue,
                      ),
                      title: Text(
                        playlist.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        final selectedIds = ref
                            .read(selectionControllerProvider)
                            .selectedSongIds;
                        final controller = ref.read(
                          playlistsControllerProvider,
                        );

                        for (final songId in selectedIds) {
                          await controller.addSongToPlaylist(
                            playlist.id,
                            songId,
                          );
                        }
                        ref
                            .read(selectionControllerProvider.notifier)
                            .exitSelectionMode();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color.withValues(alpha: 0.9), size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color.withValues(alpha: 0.6),
                fontSize: 9,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

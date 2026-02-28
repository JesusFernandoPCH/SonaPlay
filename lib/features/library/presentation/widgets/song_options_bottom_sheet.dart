import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:SonaPlay/features/library/domain/entities/song.dart';
import 'package:SonaPlay/features/library/presentation/providers/hidden_songs_provider.dart';
import 'package:SonaPlay/features/library/presentation/providers/deleted_songs_provider.dart';
import 'package:SonaPlay/features/library/presentation/providers/playlists_provider.dart';
import 'package:SonaPlay/features/library/presentation/screens/metadata_editor_screen.dart';
import 'package:SonaPlay/features/library/presentation/screens/ringtone_trimmer_screen.dart';
import 'package:SonaPlay/features/library/presentation/widgets/custom_artwork_widget.dart';
import 'package:SonaPlay/features/player/presentation/providers/audio_provider.dart';

/// Shows a unified, premium song options bottom sheet
void showSongOptionsBottomSheet({
  required BuildContext context,
  required WidgetRef ref,
  required Song song,
  List<Song>? playlist,
  int? index,
}) {
  final audioController = ref.read(audioControllerProvider);
  final hiddenSongsController = ref.read(hiddenSongsControllerProvider);
  final deletedSongsController = ref.read(deletedSongsControllerProvider);

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F111A).withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header with Artwork & Details
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  CustomArtworkWidget(
                    songId: int.parse(song.id),
                    size: 64,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          song.artist,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MetadataEditorScreen(song: song),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Actions List
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  _OptionTile(
                    icon: Icons.playlist_add_rounded,
                    label: 'Agregar a la lista de reproducción',
                    onTap: () {
                      Navigator.pop(context);
                      _showAddToPlaylistDialog(context, ref, song);
                    },
                  ),
                  _OptionTile(
                    icon: Icons.share_outlined,
                    label: 'Compartir',
                    onTap: () async {
                      Navigator.pop(context);
                      await Share.shareXFiles([
                        XFile(song.filePath),
                      ], text: '${song.title} - ${song.artist}');
                    },
                  ),
                  _OptionTile(
                    icon: Icons.speed_rounded,
                    label: 'Velocidad',
                    onTap: () {
                      Navigator.pop(context);
                      _showSpeedDialog(context, audioController);
                    },
                  ),
                  _OptionTile(
                    icon: Icons.notifications_none_rounded,
                    label: 'Establecer como tono de llamada',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RingtoneTrimmerScreen(
                            audioPath: song.filePath,
                            songTitle: song.title,
                          ),
                        ),
                      );
                    },
                  ),
                  _OptionTile(
                    icon: Icons.nights_stay_outlined,
                    label: 'Temporizador para dormir',
                    onTap: () {
                      Navigator.pop(context);
                      _showSleepTimerDialog(context, audioController);
                    },
                  ),
                  _OptionTile(
                    icon: Icons.visibility_off_outlined,
                    label: 'Ocultar',
                    onTap: () async {
                      Navigator.pop(context);
                      await hiddenSongsController.hideSong(song.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Canción ocultada')),
                        );
                      }
                    },
                  ),
                  _OptionTile(
                    icon: Icons.delete_outline_rounded,
                    label: 'Borrar',
                    labelColor: Colors.redAccent,
                    iconColor: Colors.redAccent,
                    onTap: () {
                      Navigator.pop(context);
                      _showDeleteConfirmation(
                        context,
                        song,
                        deletedSongsController,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _showSpeedDialog(BuildContext context, AudioController controller) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1A1D2E),
      title: const Text(
        'Velocidad de reproducción',
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
          return ListTile(
            title: Text(
              '${speed}x',
              style: const TextStyle(color: Colors.white70),
            ),
            onTap: () {
              controller.setSpeed(speed);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    ),
  );
}

void _showSleepTimerDialog(BuildContext context, AudioController controller) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1A1D2E),
      title: const Text(
        'Temporizador para dormir',
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [15, 30, 45, 60].map((minutes) {
          return ListTile(
            title: Text(
              '$minutes minutos',
              style: const TextStyle(color: Colors.white70),
            ),
            onTap: () {
              Future.delayed(Duration(minutes: minutes), () {
                controller.pause();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Temporizador establecido en $minutes minutos'),
                ),
              );
            },
          );
        }).toList(),
      ),
    ),
  );
}

void _showDeleteConfirmation(
  BuildContext context,
  Song song,
  DeletedSongsController controller,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1A1D2E),
      title: const Text(
        '¿Borrar canción?',
        style: TextStyle(color: Colors.white),
      ),
      content: Text(
        '¿Estás seguro de que quieres eliminar "${song.title}"? Se moverá a "Eliminado Recientemente" en la configuración.',
        style: const TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () async {
            await controller.softDeleteSong(song.id);
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Canción movida a Eliminado Recientemente'),
                ),
              );
            }
          },
          child: const Text(
            'Borrar',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    ),
  );
}

void _showAddToPlaylistDialog(BuildContext context, WidgetRef ref, Song song) {
  final playlists = ref.read(playlistsStreamProvider).value ?? [];
  final playlistsController = ref.read(playlistsControllerProvider);

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F111A).withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Text(
                'Agregar a Playlist',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (playlists.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No hay playlists disponibles',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: playlists.length,
                padding: const EdgeInsets.only(bottom: 24),
                itemBuilder: (context, index) {
                  final p = playlists[index];
                  return _OptionTile(
                    icon: Icons.playlist_add_rounded,
                    label: p.name,
                    onTap: () async {
                      Navigator.pop(context);
                      await playlistsController.addSongToPlaylist(
                        p.id,
                        song.id,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Agregado a ${p.name}')),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;
  final Color labelColor;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = Colors.white70,
    this.labelColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 24),
      title: Text(
        label,
        style: TextStyle(
          color: labelColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}

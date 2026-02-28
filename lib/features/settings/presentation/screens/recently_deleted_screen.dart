import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SonaPlay/core/presentation/widgets/vibrant_background.dart';
import 'package:SonaPlay/features/library/presentation/providers/library_provider.dart';
import 'package:SonaPlay/features/library/presentation/providers/deleted_songs_provider.dart';
import 'package:SonaPlay/features/library/presentation/widgets/song_list_tile.dart';
import 'package:SonaPlay/features/player/presentation/providers/palette_provider.dart';

class RecentlyDeletedScreen extends ConsumerWidget {
  const RecentlyDeletedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deletedIdsAsync = ref.watch(deletedSongsStreamProvider);
    final allSongsAsync = ref.watch(songsProvider);
    final deletedController = ref.read(deletedSongsControllerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Eliminado Recientemente'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          VibrantBackground(accentColor: ref.watch(dominantColorProvider)),
          deletedIdsAsync.when(
            data: (deletedIds) {
              if (deletedIds.isEmpty) {
                return const Center(
                  child: Text(
                    'La papelera está vacía',
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              }

              return allSongsAsync.when(
                data: (allSongs) {
                  final deletedSongs = allSongs
                      .where((song) => deletedIds.contains(song.id))
                      .toList();

                  if (deletedSongs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No se encontraron canciones eliminadas',
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: deletedSongs.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      final song = deletedSongs[index];
                      return SongListTile(
                        song: song,
                        index: index,
                        playlist: deletedSongs,
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.restore_from_trash_rounded,
                            color: Colors.greenAccent,
                          ),
                          onPressed: () async {
                            await deletedController.restoreSong(song.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${song.title} restaurada'),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ],
      ),
    );
  }
}

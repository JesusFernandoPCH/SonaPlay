import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SonaPlay/core/presentation/widgets/vibrant_background.dart';
import 'package:SonaPlay/features/library/presentation/providers/library_provider.dart';
import 'package:SonaPlay/features/library/presentation/providers/playlists_provider.dart';
import 'package:SonaPlay/features/library/presentation/providers/selection_provider.dart';
import 'package:SonaPlay/features/library/presentation/widgets/song_list_tile.dart';
import 'package:SonaPlay/features/player/presentation/providers/audio_provider.dart';
import 'package:SonaPlay/features/player/presentation/providers/palette_provider.dart';
import 'package:SonaPlay/features/player/presentation/widgets/sona_mini_player.dart';

/// Screen showing songs in a specific playlist
class PlaylistDetailScreen extends ConsumerWidget {
  final String playlistId;

  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistAsync = ref.watch(playlistProvider(playlistId));
    final allSongsAsync = ref.watch(songsProvider);
    final selectionState = ref.watch(selectionControllerProvider);

    return PopScope(
      canPop: !selectionState.isSelectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && selectionState.isSelectionMode) {
          ref.read(selectionControllerProvider.notifier).exitSelectionMode();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            VibrantBackground(accentColor: ref.watch(dominantColorProvider)),
            playlistAsync.when(
              data: (playlist) {
                if (playlist == null) {
                  return const Center(child: Text('Playlist not found'));
                }

                return allSongsAsync.when(
                  data: (allSongs) {
                    final playlistSongs = allSongs
                        .where((song) => playlist.songIds.contains(song.id))
                        .toList();

                    // Reorder to match playlist order
                    playlistSongs.sort((a, b) {
                      final indexA = playlist.songIds.indexOf(a.id);
                      final indexB = playlist.songIds.indexOf(b.id);
                      return indexA.compareTo(indexB);
                    });

                    return CustomScrollView(
                      slivers: [
                        // Modern Header
                        SliverAppBar(
                          expandedHeight: 350,
                          pinned: true,
                          backgroundColor: Colors.transparent,
                          flexibleSpace: FlexibleSpaceBar(
                            background: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Playlist Info Content
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 60),
                                    // Floating Artwork
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.4),
                                            blurRadius: 30,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.playlist_play_rounded,
                                        size: 150,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      playlist.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${playlistSongs.length} Songs',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Glowing Play Button
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.3),
                                            blurRadius: 15,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: FilledButton.icon(
                                        onPressed: () {
                                          if (playlistSongs.isNotEmpty) {
                                            ref
                                                .read(audioControllerProvider)
                                                .play(
                                                  playlistSongs.first,
                                                  playlistSongs,
                                                  0,
                                                );
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.play_arrow_rounded,
                                        ),
                                        label: const Text('Shuffle Play'),
                                        style: FilledButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 32,
                                            vertical: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          leading: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        // Song List
                        SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final song = playlistSongs[index];
                            return Dismissible(
                              key: Key('${playlistId}_${song.id}_$index'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Theme.of(context).colorScheme.error,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 16),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              confirmDismiss: (direction) async {
                                final controller = ref.read(
                                  playlistsControllerProvider,
                                );
                                await controller.removeSongFromPlaylist(
                                  playlistId,
                                  song.id,
                                );
                                return true;
                              },
                              child: SongListTile(
                                song: song,
                                index: index,
                                playlist: playlistSongs,
                              ),
                            );
                          }, childCount: playlistSongs.length),
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 100 + MediaQuery.of(context).padding.bottom,
                          ),
                        ), // Bottom spacing
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) =>
                      const Center(child: Text('Error loading songs')),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => const Center(child: Text('Error')),
            ),
          ],
        ),
        bottomNavigationBar: const SafeArea(
          top: false,
          child: SonaMiniPlayer(),
        ),
      ),
    );
  }
}

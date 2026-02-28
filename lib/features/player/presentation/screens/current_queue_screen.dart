import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SonaPlay/features/library/presentation/widgets/song_list_tile.dart';
import 'package:SonaPlay/features/player/presentation/providers/audio_provider.dart';
import 'package:SonaPlay/features/player/presentation/providers/palette_provider.dart';
import 'package:SonaPlay/core/presentation/widgets/vibrant_background.dart';
import 'package:SonaPlay/features/player/presentation/widgets/sona_mini_player.dart';
import 'package:SonaPlay/features/player/domain/entities/player_state.dart'
    as ps;

class CurrentQueueScreen extends ConsumerWidget {
  const CurrentQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(currentQueueProvider);
    final currentIndex = ref.watch(currentIndexProvider);
    final isShuffled = ref.watch(isShuffledProvider);
    final repeatMode = ref.watch(repeatModeProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. Vibrant Background
          VibrantBackground(accentColor: ref.watch(dominantColorProvider)),

          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                // Custom Header
                _buildHeader(context, ref, isShuffled, repeatMode),
                const SizedBox(height: 24),
                // Queue List
                Expanded(
                  child: queue.isEmpty
                      ? _buildEmptyState(context)
                      : Theme(
                          data: Theme.of(context).copyWith(
                            canvasColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: ReorderableListView.builder(
                            key: const PageStorageKey(
                              'queue_list',
                            ), // Preservar scroll
                            padding: EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: 8,
                              bottom:
                                  180 + MediaQuery.of(context).padding.bottom,
                            ),
                            itemCount: queue.length,
                            onReorder: (oldIndex, newIndex) {
                              ref
                                  .read(audioControllerProvider)
                                  .reorderQueue(oldIndex, newIndex);
                            },
                            itemBuilder: (context, index) {
                              final song = queue[index];
                              final isActive = index == currentIndex;

                              return SongListTile(
                                key: ValueKey('queue_${song.id}_$index'),
                                song: song,
                                index: index,
                                playlist: queue,
                                trailing: ReorderableDragStartListener(
                                  index: index,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    child: Icon(
                                      Icons.drag_handle,
                                      color: isActive
                                          ? const Color(
                                              0xFF0D59F2,
                                            ).withValues(alpha: 0.6)
                                          : Colors.white.withValues(alpha: 0.3),
                                    ),
                                  ),
                                ),
                                onLongPress: () {},
                                onTapCurrentSong: () => Navigator.pop(context),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),

          // 3. Bottom Controls Panel
          // Legacy _BottomControlsPanel removed.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: SonaMiniPlayer(onTap: () => Navigator.pop(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    bool isShuffled,
    ps.RepeatMode repeatMode,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: const Icon(Icons.expand_more, color: Colors.white),
            ),
          ),
          const Column(
            children: [
              Text(
                'LISTA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          Row(
            children: [
              // Shuffle Button
              IconButton(
                onPressed: () =>
                    ref.read(audioControllerProvider).toggleShuffle(),
                icon: Icon(
                  Icons.shuffle,
                  color: isShuffled
                      ? const Color(0xFF0D59F2)
                      : Colors.white.withValues(alpha: 0.5),
                  size: 24,
                ),
              ),
              // Repeat Button
              IconButton(
                onPressed: () =>
                    ref.read(audioControllerProvider).toggleRepeat(),
                icon: Icon(
                  repeatMode == ps.RepeatMode.one
                      ? Icons.repeat_one
                      : Icons.repeat,
                  color:
                      repeatMode == ps.RepeatMode.one ||
                          repeatMode == ps.RepeatMode.all
                      ? const Color(0xFF0D59F2)
                      : Colors.white.withValues(alpha: 0.5),
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.queue_music,
            size: 64,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay canciones en la lista',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// Removed legacy internal queue widgets.
// Reordering is now handled by the shared SongListTile with a custom trailing widget.

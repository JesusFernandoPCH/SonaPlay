import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SonaPlay/core/constants/app_colors.dart';
import 'package:SonaPlay/core/presentation/widgets/glass_container.dart';
import 'package:SonaPlay/core/presentation/widgets/vibrant_background.dart';
import 'package:SonaPlay/features/library/presentation/widgets/custom_artwork_widget.dart';
import 'package:SonaPlay/features/library/presentation/providers/favorites_provider.dart';
import 'package:SonaPlay/features/library/presentation/widgets/song_options_bottom_sheet.dart';
import 'package:SonaPlay/features/library/domain/entities/song.dart';
import 'package:SonaPlay/features/player/presentation/providers/audio_provider.dart';
import 'package:SonaPlay/features/player/presentation/screens/current_queue_screen.dart';
import 'package:SonaPlay/features/player/presentation/providers/palette_provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:share_plus/share_plus.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSongAsync = ref.watch(currentSongProvider);
    final favoritesAsync = ref.watch(favoritesStreamProvider);
    final playlist = ref.watch(currentQueueProvider);
    final index = ref.watch(currentIndexProvider);

    final song = currentSongAsync.value;
    final favoriteIds = favoritesAsync.value ?? [];
    final isFavorite = song != null && favoriteIds.contains(song.id);

    if (song == null) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundDarkBlue,
        body: Center(
          child: Text('No song playing', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // 1. Vibrant Background
          VibrantBackground(accentColor: ref.watch(dominantColorProvider)),

          // 2. Main Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Custom Header
                        _buildHeader(context, ref, song, playlist, index),

                        const SizedBox(height: 16),

                        // Interactive Area (Artwork + Metadata) to minimize player
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            children: [
                              // Artwork Section
                              _buildArtwork(
                                context,
                                song,
                                constraints.maxHeight,
                              ),
                              const SizedBox(height: 32),
                              // Metadata Section
                              _buildMetadata(context, song),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Controls Panel
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              const _GlassControlsPanel(),
                              const SizedBox(height: 24),
                              _buildBottomActions(
                                context,
                                ref,
                                song,
                                isFavorite,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    Song song,
    List<Song>? playlist,
    int? index,
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
                'SONAPLAY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              showSongOptionsBottomSheet(
                context: context,
                ref: ref,
                song: song,
                playlist: playlist,
                index: index,
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: const Icon(Icons.more_horiz, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtwork(BuildContext context, Song song, double maxHeight) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate artwork size based on width but constrained by height
    double artworkSize = screenWidth * 0.75;

    // If height is tight (split screen), shrink the artwork
    if (maxHeight < 600) {
      artworkSize = maxHeight * 0.35;
    }

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow effect
          Container(
            width: artworkSize * 0.9,
            height: artworkSize * 0.9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5B13EC).withValues(alpha: 0.4),
                  blurRadius: 80,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          // Artwork card
          Hero(
            tag: 'artwork_${song.id}',
            child: Container(
              width: artworkSize,
              height: artworkSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: CustomArtworkWidget(
                  songId: int.parse(song.id),
                  artworkPath: song.artworkPath,
                  size: artworkSize,
                  quality: 100,
                  format: ArtworkFormat
                      .PNG, // PNG for better clarity where possible
                  borderRadius: BorderRadius.zero, // Controlled by ClipRRect
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata(BuildContext context, Song song) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            song.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            song.artist,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(
    BuildContext context,
    WidgetRef ref,
    Song song,
    bool isFavorite,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Next Up Button
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CurrentQueueScreen(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withValues(alpha: 0.05),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: const Row(
              children: [
                Icon(Icons.playlist_play, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'COLA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        // IconButton Group
        Row(
          children: [
            _buildActionIcon(Icons.equalizer, () {}),
            const SizedBox(width: 12),
            _buildActionIcon(Icons.share, () {
              Share.shareXFiles([XFile(song.filePath)]);
            }),
            const SizedBox(width: 12),
            _buildActionIcon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              () {
                ref.read(favoritesControllerProvider).toggleFavorite(song.id);
              },
              color: isFavorite ? const Color(0xFF5B13EC) : Colors.white,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionIcon(
    IconData icon,
    VoidCallback onTap, {
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

// Local providers for scrubbing state
final isDraggingProvider = StateProvider.autoDispose<bool>((ref) => false);
final dragPositionProvider = StateProvider.autoDispose<Duration>(
  (ref) => Duration.zero,
);

class _GlassControlsPanel extends ConsumerWidget {
  const _GlassControlsPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(positionProvider);
    final duration = ref.watch(durationProvider);
    final isPlaying = ref.watch(isPlayingProvider);
    final isDragging = ref.watch(isDraggingProvider);
    final dragPosition = ref.watch(dragPositionProvider);

    // Use drag position if scrubbing, otherwise use real position
    final currentPosition = isDragging ? dragPosition : position;

    final progress = duration.inMilliseconds > 0
        ? currentPosition.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return GlassContainer(
      borderRadius: BorderRadius.circular(24),
      opacity: 0.03,
      blur: 24,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Seek Bar
          Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragStart: (details) {
                      ref.read(isDraggingProvider.notifier).state = true;
                      ref.read(dragPositionProvider.notifier).state = position;
                    },
                    onHorizontalDragUpdate: (details) {
                      final double relative =
                          details.localPosition.dx / constraints.maxWidth;
                      final int newPos = (relative * duration.inMilliseconds)
                          .toInt();
                      ref.read(dragPositionProvider.notifier).state = Duration(
                        milliseconds: newPos.clamp(0, duration.inMilliseconds),
                      );
                    },
                    onHorizontalDragEnd: (details) {
                      final finalPos = ref.read(dragPositionProvider);
                      ref.read(controlPlaybackUseCaseProvider).seek(finalPos);
                      ref.read(isDraggingProvider.notifier).state = false;
                    },
                    onTapDown: (details) {
                      // For quick taps, we seek immediately but also handle it gracefully
                      final double relative =
                          details.localPosition.dx / constraints.maxWidth;
                      final int newPos = (relative * duration.inMilliseconds)
                          .toInt();
                      final targetDuration = Duration(
                        milliseconds: newPos.clamp(0, duration.inMilliseconds),
                      );
                      ref
                          .read(controlPlaybackUseCaseProvider)
                          .seek(targetDuration);
                    },
                    child: Container(
                      height: 40, // Expanded hit area
                      color: Colors.transparent,
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          // Background bar
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          // Progress bar
                          FractionallySizedBox(
                            widthFactor: progress.clamp(0.0, 1.0),
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: const Color(0xFF5B13EC),
                                borderRadius: BorderRadius.circular(3),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF5B13EC,
                                    ).withValues(alpha: 0.8),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Thumb
                          Positioned(
                            left:
                                (progress.clamp(0.0, 1.0) *
                                    constraints.maxWidth) -
                                8,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(currentPosition),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _formatDuration(duration),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Playback Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 20),
              IconButton(
                onPressed: () =>
                    ref.read(controlPlaybackUseCaseProvider).skipToPrevious(),
                icon: const Icon(
                  Icons.skip_previous,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 40),
              GestureDetector(
                onTap: () {
                  final control = ref.read(controlPlaybackUseCaseProvider);
                  if (isPlaying) {
                    control.pause();
                  } else {
                    control.resume();
                  }
                },
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 36,
                    color: const Color(0xFF161022),
                  ),
                ),
              ),
              const SizedBox(width: 40),
              IconButton(
                onPressed: () =>
                    ref.read(controlPlaybackUseCaseProvider).skipToNext(),
                icon: const Icon(
                  Icons.skip_next,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}

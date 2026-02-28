import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SonaPlay/core/constants/app_colors.dart';
import 'package:SonaPlay/core/presentation/widgets/glass_container.dart';
import 'package:SonaPlay/features/library/presentation/widgets/custom_artwork_widget.dart';
import 'package:SonaPlay/features/player/presentation/providers/audio_provider.dart';
import 'package:SonaPlay/features/player/presentation/screens/player_screen.dart';

class SonaMiniPlayer extends ConsumerWidget {
  final VoidCallback? onTap;

  const SonaMiniPlayer({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSongAsync = ref.watch(currentSongProvider);
    final currentSong = currentSongAsync.value;
    if (currentSong == null) return const SizedBox.shrink();

    final isPlaying = ref.watch(isPlayingProvider);
    final position = ref.watch(positionProvider);
    final duration = ref.watch(durationProvider);
    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap:
            onTap ??
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PlayerScreen()),
              );
            },
        child: GlassContainer(
          borderRadius: BorderRadius.circular(20),
          opacity: 0.1,
          showBorder: true,
          borderColor: Colors.white.withValues(alpha: 0.2),
          child: Stack(
            children: [
              // Progress Bar at the Top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(alpha: 0.6),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    // Album Art
                    CustomArtworkWidget(
                      songId: int.parse(currentSong.id),
                      artworkPath: currentSong.artworkPath,
                      size: 44,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const SizedBox(width: 12),
                    // Song Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currentSong.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentSong.artist.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Controls
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.skip_previous,
                            size: 28,
                            color: Colors.white,
                          ),
                          onPressed: () => ref
                              .read(audioControllerProvider)
                              .skipToPrevious(),
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              size: 28,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              if (isPlaying) {
                                ref.read(audioControllerProvider).pause();
                              } else {
                                ref.read(audioControllerProvider).resume();
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.skip_next,
                            size: 28,
                            color: Colors.white,
                          ),
                          onPressed: () =>
                              ref.read(audioControllerProvider).skipToNext(),
                        ),
                      ],
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
}

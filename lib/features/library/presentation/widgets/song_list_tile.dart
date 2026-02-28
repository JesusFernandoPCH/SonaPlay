import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SonaPlay/core/constants/app_colors.dart';
import 'package:SonaPlay/core/constants/app_dimensions.dart';
import 'package:SonaPlay/core/presentation/widgets/glass_container.dart';
import 'package:SonaPlay/features/library/domain/entities/song.dart';
import 'package:SonaPlay/features/library/presentation/providers/favorites_provider.dart';
import 'package:SonaPlay/features/library/presentation/providers/library_provider.dart';
import 'package:SonaPlay/features/library/presentation/providers/selection_provider.dart';
import 'package:SonaPlay/features/library/presentation/widgets/custom_artwork_widget.dart';
import 'package:SonaPlay/features/library/presentation/widgets/song_options_bottom_sheet.dart';
import 'package:SonaPlay/features/player/presentation/providers/audio_provider.dart';
import 'package:SonaPlay/features/player/presentation/screens/player_screen.dart';

/// Widget to display a song in a list
class SongListTile extends ConsumerWidget {
  final Song song;
  final int index;
  final List<Song>? playlist;
  final Widget? trailing; // New: Custom trailing widget (e.g., drag handle)
  final VoidCallback?
  onTapCurrentSong; // New: Navigation override for current song
  final VoidCallback? onLongPress; // New: Long press override

  const SongListTile({
    super.key,
    required this.song,
    required this.index,
    this.playlist,
    this.trailing,
    this.onTapCurrentSong,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only rebuild when current song ID or playing state changes
    final currentSongId = ref.watch(currentSongIdProvider);
    final isCurrentSong = currentSongId == song.id;

    // Only watch isPlaying if this is the current song
    final isPlaying = isCurrentSong ? ref.watch(isPlayingProvider) : false;

    // Watch favorite status
    final isFavoriteAsync = ref.watch(isFavoriteProvider(song.id));

    // Watch selection state (Ajuste 2)
    final selectionState = ref.watch(selectionControllerProvider);
    final isSelected = selectionState.isSelected(song.id);
    final isSelectionMode = selectionState.isSelectionMode;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: 4,
      ),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        opacity: isCurrentSong ? 0.12 : 0.0,
        showBorder: isCurrentSong,
        color: isCurrentSong ? AppColors.primary : Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          onTap: () {
            if (isSelectionMode) {
              ref
                  .read(selectionControllerProvider.notifier)
                  .toggleSelection(song.id);
              return;
            }

            if (isCurrentSong) {
              if (onTapCurrentSong != null) {
                onTapCurrentSong!();
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PlayerScreen()),
                );
              }
              return;
            }

            final controller = ref.read(audioControllerProvider);
            final playbackSource = playlist ?? ref.read(songsProvider).value;
            if (playbackSource != null && playbackSource.isNotEmpty) {
              controller.play(song, playbackSource, index);
            }
          },
          onLongPress:
              onLongPress ??
              () {
                if (!isSelectionMode) {
                  ref
                      .read(selectionControllerProvider.notifier)
                      .enterSelectionMode(song.id);
                } else {
                  ref
                      .read(selectionControllerProvider.notifier)
                      .toggleSelection(song.id);
                }
              },
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingSmall),
            child: Row(
              children: [
                // Premium Artwork
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMedium,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                          if (isCurrentSong)
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 15,
                              spreadRadius: 1,
                            ),
                        ],
                      ),
                      child: RepaintBoundary(
                        child: CustomArtworkWidget(
                          songId: int.parse(song.id),
                          artworkPath: song.artworkPath,
                          size: 56,
                          quality:
                              50, // Lower quality for list view performance
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMedium,
                          ),
                        ),
                      ),
                    ),
                    if (isSelectionMode)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMedium,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.white70,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: AppDimensions.paddingMedium),
                // Song Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: isCurrentSong
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: isCurrentSong
                                  ? AppColors.primaryLight
                                  : AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isCurrentSong
                              ? AppColors.primaryLight.withValues(alpha: 0.7)
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Trailing actions and status
                if (trailing != null)
                  trailing!
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isCurrentSong && isPlaying)
                        const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Icon(
                            Icons.bar_chart_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                      isFavoriteAsync.when(
                        data: (isFavorite) => IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite
                                ? AppColors.accent
                                : AppColors.textTertiary,
                            size: 20,
                          ),
                          onPressed: () {
                            ref
                                .read(favoritesControllerProvider)
                                .toggleFavorite(song.id);
                          },
                        ),
                        loading: () => const SizedBox(width: 40),
                        error: (_, _) => const SizedBox(width: 40),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert_rounded, size: 20),
                        color: AppColors.textTertiary,
                        onPressed: () => showSongOptionsBottomSheet(
                          context: context,
                          ref: ref,
                          song: song,
                          playlist: playlist,
                          index: index,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

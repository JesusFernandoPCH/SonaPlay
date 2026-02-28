import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SonaPlay/core/constants/app_colors.dart';
import 'package:SonaPlay/core/presentation/widgets/vibrant_background.dart';
import 'package:SonaPlay/features/library/domain/entities/folder.dart';
import 'package:SonaPlay/features/player/presentation/providers/palette_provider.dart';
import 'package:SonaPlay/features/library/presentation/widgets/song_list_tile.dart';
import 'package:SonaPlay/features/player/presentation/providers/audio_provider.dart';
import 'package:SonaPlay/features/player/presentation/widgets/sona_mini_player.dart';

class FolderDetailScreen extends ConsumerWidget {
  final Folder folder;

  const FolderDetailScreen({super.key, required this.folder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkBlue,
      body: Stack(
        children: [
          // Background Gradient
          VibrantBackground(accentColor: ref.watch(dominantColorProvider)),

          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    folder.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Center(
                    child: Icon(
                      Icons.folder_rounded,
                      size: 100,
                      color: AppColors.primaryBlue.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // Folder Info & Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        folder.path,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            '${folder.songCount} canciones',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          FilledButton.icon(
                            onPressed: () {
                              if (folder.songs.isNotEmpty) {
                                ref
                                    .read(audioControllerProvider)
                                    .play(folder.songs.first, folder.songs, 0);
                              }
                            },
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('Reproducir Todo'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Song List
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final song = folder.songs[index];
                  return SongListTile(
                    song: song,
                    index: index,
                    playlist: folder.songs,
                  );
                }, childCount: folder.songs.length),
              ),

              // Bottom Spacing
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),

          // Mini Player
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: const SafeArea(top: false, child: SonaMiniPlayer()),
          ),
        ],
      ),
    );
  }
}

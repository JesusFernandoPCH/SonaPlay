import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SonaPlay/core/constants/app_colors.dart';
import 'package:SonaPlay/core/presentation/widgets/glass_container.dart';
import 'package:SonaPlay/features/library/domain/entities/playlist.dart';
import 'package:SonaPlay/features/library/presentation/providers/playlists_provider.dart';
import 'package:SonaPlay/features/library/presentation/screens/playlist_detail_screen.dart';
import 'package:SonaPlay/features/library/presentation/widgets/create_playlist_dialog.dart';
import 'package:SonaPlay/features/library/presentation/widgets/custom_artwork_widget.dart';

/// Screen showing all user playlists with a premium design
class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer(
      builder: (context, ref, child) {
        final playlistsAsync = ref.watch(playlistsStreamProvider);

        return playlistsAsync.when(
          data: (playlists) {
            return SingleChildScrollView(
              key: const PageStorageKey('playlists_scroll'), // Preservar scroll
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom:
                    140 +
                    MediaQuery.of(
                      context,
                    ).padding.bottom, // Space for miniplayer + system nav
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Create New Playlist Card
                  _CreatePlaylistCard(
                    onTap: () => _showCreatePlaylistDialog(context),
                  ),
                  const SizedBox(height: 16),

                  // Playlists List
                  if (playlists.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.playlist_add_rounded,
                              size: 64,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No playlists yet',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: playlists.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _PlaylistCard(playlist: playlists[index]);
                      },
                    ),
                ],
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          ),
          error: (error, stack) => Center(
            child: Text(
              'Error loading playlists: $error',
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        );
      },
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreatePlaylistDialog(),
    );
  }
}

class _CreatePlaylistCard extends StatelessWidget {
  final VoidCallback onTap;

  const _CreatePlaylistCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        borderRadius: BorderRadius.circular(20),
        opacity: 0.03,
        showBorder: true,
        borderColor: Colors.white.withValues(alpha: 0.15),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryBlue.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.primaryBlue,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Crea una nueva playlist',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaylistCard extends ConsumerWidget {
  final Playlist playlist;

  const _PlaylistCard({required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaylistDetailScreen(playlistId: playlist.id),
          ),
        );
      },
      child: GlassContainer(
        borderRadius: BorderRadius.circular(20),
        opacity: 0.03,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _PlaylistCollage(songIds: playlist.songIds),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${playlist.songIds.length} songs',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _showPlaylistOptions(context, ref),
              icon: Icon(
                Icons.more_vert,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlaylistOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF101622),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white70),
              title: const Text(
                'Rename',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: const Text(
                'Delete',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: playlist.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B2A),
        title: const Text(
          'Rename Playlist',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Playlist name',
            labelStyle: const TextStyle(color: Colors.white54),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryBlue),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          FilledButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await ref
                    .read(playlistsControllerProvider)
                    .renamePlaylist(playlist.id, controller.text.trim());
                if (context.mounted) Navigator.pop(context);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
            ),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B2A),
        title: const Text(
          'Delete Playlist',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${playlist.name}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          FilledButton(
            onPressed: () async {
              await ref
                  .read(playlistsControllerProvider)
                  .deletePlaylist(playlist.id);
              if (context.mounted) Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _PlaylistCollage extends ConsumerWidget {
  final List<String> songIds;

  const _PlaylistCollage({required this.songIds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double size = 56.0;
    const double borderRadius = 12.0;

    if (songIds.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: const Icon(Icons.music_note, color: Colors.white24),
      );
    }

    // If we have at least 1 but less than 4, we show the first one large
    if (songIds.length < 4) {
      return CustomArtworkWidget(
        songId: int.parse(songIds.first),
        size: size,
        borderRadius: BorderRadius.circular(borderRadius),
      );
    }

    // 2x2 Grid for collage
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            return CustomArtworkWidget(
              songId: int.parse(songIds[index]),
              size: size / 2,
              borderRadius: BorderRadius.zero,
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SonaPlay/core/constants/app_colors.dart';
import 'package:SonaPlay/core/presentation/widgets/glass_container.dart';
import 'package:SonaPlay/features/library/domain/entities/folder.dart';
import 'package:SonaPlay/features/library/presentation/providers/folders_provider.dart';
import 'package:SonaPlay/features/library/presentation/screens/folder_detail_screen.dart';
import 'package:SonaPlay/features/library/presentation/widgets/custom_artwork_widget.dart';

class FoldersTab extends ConsumerWidget {
  const FoldersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersAsync = ref.watch(foldersProvider);

    return foldersAsync.when(
      data: (folders) {
        if (folders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_open_rounded,
                  size: 80,
                  color: Colors.white24,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No se encontraron carpetas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Asegúrate de tener música en tu dispositivo',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          key: const PageStorageKey('folders_list'),
          padding: const EdgeInsets.only(
            top: 24,
            bottom: 120,
            left: 16,
            right: 16,
          ),
          itemCount: folders.length,
          itemBuilder: (context, index) {
            final folder = folders[index];
            return _FolderCard(folder: folder);
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      ),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}

class _FolderCard extends StatelessWidget {
  final Folder folder;

  const _FolderCard({required this.folder});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FolderDetailScreen(folder: folder),
            ),
          );
        },
        child: GlassContainer(
          borderRadius: BorderRadius.circular(20),
          opacity: 0.03,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _FolderArtwork(folder: folder),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      folder.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${folder.songCount} canciones',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      folder.path,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FolderArtwork extends StatelessWidget {
  final Folder folder;

  const _FolderArtwork({required this.folder});

  @override
  Widget build(BuildContext context) {
    const double size = 56.0;
    const double borderRadius = 12.0;

    return Stack(
      children: [
        if (folder.songs.isNotEmpty)
          CustomArtworkWidget(
            songId: int.parse(folder.songs.first.id),
            artworkPath: folder.songs.first.artworkPath,
            size: size,
            borderRadius: BorderRadius.circular(borderRadius),
          )
        else
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: const Icon(Icons.folder, color: Colors.white24, size: 32),
          ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: const Center(
              child: Icon(
                Icons.folder_rounded,
                color: Colors.white70,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

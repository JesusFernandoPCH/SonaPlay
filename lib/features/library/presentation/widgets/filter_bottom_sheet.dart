import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SonaPlay/features/library/presentation/providers/search_filter_provider.dart';

/// Bottom sheet for filtering songs by artist and album
class FilterBottomSheet extends ConsumerWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedArtist = ref.watch(selectedArtistProvider);
    final selectedAlbum = ref.watch(selectedAlbumProvider);
    final artists = ref.watch(uniqueArtistsProvider);
    final albums = ref.watch(uniqueAlbumsProvider);

    final hasActiveFilters = selectedArtist != null || selectedAlbum != null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filters', style: Theme.of(context).textTheme.titleLarge),
                if (hasActiveFilters)
                  TextButton(
                    onPressed: () {
                      ref.read(selectedArtistProvider.notifier).update(null);
                      ref.read(selectedAlbumProvider.notifier).update(null);
                    },
                    child: const Text('Clear All'),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Artist filter
            Text('Artist', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              isExpanded: true,
              initialValue: selectedArtist,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              hint: const Text('All Artists'),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Artists')),
                ...artists.map(
                  (artist) => DropdownMenuItem(
                    value: artist,
                    child: Text(
                      artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
              onChanged: (value) {
                ref.read(selectedArtistProvider.notifier).update(value);
              },
            ),
            const SizedBox(height: 16),

            // Album filter
            Text('Album', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              isExpanded: true,
              initialValue: selectedAlbum,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              hint: const Text('All Albums'),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Albums')),
                ...albums.map(
                  (album) => DropdownMenuItem(
                    value: album,
                    child: Text(
                      album,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
              onChanged: (value) {
                ref.read(selectedAlbumProvider.notifier).update(value);
              },
            ),
            const SizedBox(height: 24),

            // Apply button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Apply'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

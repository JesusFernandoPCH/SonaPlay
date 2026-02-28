import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SonaPlay/core/presentation/widgets/vibrant_background.dart';
import 'package:SonaPlay/features/library/presentation/providers/search_filter_provider.dart';
import 'package:SonaPlay/features/library/presentation/widgets/song_list_tile.dart';
import 'package:SonaPlay/features/library/domain/entities/song.dart';
import 'package:SonaPlay/features/player/presentation/providers/palette_provider.dart';
import 'package:SonaPlay/features/player/presentation/widgets/sona_mini_player.dart';
import 'package:SonaPlay/core/presentation/widgets/glass_container.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final searchResults = ref.watch(filteredSongsProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Dynamic Background Gradient
          VibrantBackground(accentColor: ref.watch(dominantColorProvider)),
          SafeArea(
            child: Column(
              children: [
                _buildSearchBar(context),
                Expanded(
                  child: query.isEmpty
                      ? _buildEmptyState()
                      : _buildSearchResults(searchResults),
                ),
              ],
            ),
          ),
          // MiniPlayer at the bottom
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Search for songs, artists or albums',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: GlassContainer(
              borderRadius: BorderRadius.circular(15),
              child: TextField(
                controller: _searchController,
                onChanged: (value) =>
                    ref.read(searchQueryProvider.notifier).state = value,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(searchQueryProvider.notifier).state = '';
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(AsyncValue<List<Song>> results) {
    final baseSongsAsync = ref.watch(baseFilteredSongsProvider);
    final baseSongs = baseSongsAsync.value ?? [];

    return results.when(
      data: (songs) {
        if (songs.isEmpty) {
          return const Center(child: Text('No results found'));
        }
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];
            // Find index in base list for correct queue positioning
            final baseIndex = baseSongs.indexWhere((s) => s.id == song.id);

            return RepaintBoundary(
              child: SongListTile(
                song: song,
                index: baseIndex != -1 ? baseIndex : index,
                playlist: baseSongs.isNotEmpty ? baseSongs : songs,
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}

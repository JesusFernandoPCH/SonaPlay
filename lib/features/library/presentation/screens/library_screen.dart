import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SonaPlay/core/constants/app_colors.dart';
import 'package:SonaPlay/features/library/presentation/providers/favorites_provider.dart';
import 'package:SonaPlay/features/library/presentation/providers/library_provider.dart';
import 'package:SonaPlay/features/library/presentation/providers/search_filter_provider.dart';
import 'package:SonaPlay/features/library/presentation/providers/selection_provider.dart';
import 'package:SonaPlay/features/library/presentation/screens/playlists_screen.dart';
import 'package:SonaPlay/features/library/presentation/screens/search_screen.dart';
import 'package:SonaPlay/features/library/presentation/widgets/folders_tab.dart';
import 'package:SonaPlay/features/library/presentation/widgets/song_list_tile.dart';
import 'package:SonaPlay/features/player/presentation/widgets/sona_mini_player.dart';
import 'package:SonaPlay/features/library/presentation/widgets/multi_select_action_bar.dart';
import 'package:SonaPlay/core/presentation/widgets/vibrant_background.dart';
import 'package:SonaPlay/features/library/presentation/widgets/sort_menu.dart';
import 'package:SonaPlay/features/player/presentation/providers/palette_provider.dart';

import 'package:SonaPlay/features/settings/presentation/screens/settings_screen.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  @override
  Widget build(BuildContext context) {
    final selectionState = ref.watch(selectionControllerProvider);

    return PopScope(
      canPop: !selectionState.isSelectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && selectionState.isSelectionMode) {
          ref.read(selectionControllerProvider.notifier).exitSelectionMode();
        }
      },
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          backgroundColor: AppColors.backgroundDarkBlue,
          appBar: selectionState.isSelectionMode
              ? const MultiSelectHeader()
              : null,
          body: Stack(
            children: [
              // Vibrant Radial Gradient Background
              VibrantBackground(accentColor: ref.watch(dominantColorProvider)),
              SafeArea(
                child: Column(
                  children: [
                    if (!selectionState.isSelectionMode) _buildHeader(context),
                    _buildTabBar(),
                    const Expanded(
                      child: TabBarView(
                        children: [
                          _AllSongsTab(),
                          _PlaylistsTabView(),
                          _FavoritesTab(),
                          FoldersTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Floating MiniPlayer at the bottom
              if (!selectionState.isSelectionMode)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: const SafeArea(top: false, child: SonaMiniPlayer()),
                )
              else
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    top: false,
                    child: const MultiSelectBottomBar(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 32,
                  height: 32,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'SonaPlay',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildHeaderButton(
                icon: Icons.search,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchScreen(),
                    ),
                  ).then((_) {
                    ref.read(searchQueryProvider.notifier).state = '';
                  });
                },
              ),
              const SortMenu(),
              _buildHeaderButton(
                icon: Icons.settings,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: 24),
      onPressed: onPressed,
      style: IconButton.styleFrom(
        hoverColor: Colors.white10,
        padding: const EdgeInsets.all(8),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: TabBar(
        isScrollable: true,
        dividerColor: Colors.transparent,
        indicatorColor: AppColors.primaryBlue,
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 0),
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        tabAlignment: TabAlignment.start,
        tabs: const [
          Tab(text: 'Canciones'),
          Tab(text: 'Playlists'),
          Tab(text: 'Favoritos'),
          Tab(text: 'Carpetas'),
        ],
      ),
    );
  }
}

class _AllSongsTab extends StatefulWidget {
  const _AllSongsTab();

  @override
  State<_AllSongsTab> createState() => _AllSongsTabState();
}

class _AllSongsTabState extends State<_AllSongsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Consumer(
      builder: (context, ref, child) {
        final songsAsync = ref.watch(filteredSongsProvider);

        return songsAsync.when(
          data: (songs) {
            if (songs.isEmpty) {
              final allSongsAsync = ref.watch(songsProvider);
              final hasFiltersOrSearch = ref
                  .watch(searchQueryProvider)
                  .isNotEmpty;

              return allSongsAsync.maybeWhen(
                data: (allSongs) {
                  if (allSongs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.music_off_rounded,
                            size: 80,
                            color: Colors.white24,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No se encontraron canciones',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Agrega música a tu dispositivo',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (hasFiltersOrSearch) {}
                  return const SizedBox.shrink();
                },
                orElse: () => const SizedBox.shrink(),
              );
            }
            final baseSongsAsync = ref.watch(baseFilteredSongsProvider);
            final baseSongs = baseSongsAsync.value ?? [];

            return ListView.builder(
              key: const PageStorageKey('all_songs_list'), // Preservar scroll
              padding: const EdgeInsets.only(
                top: 24,
                bottom: 120,
                left: 16,
                right: 16,
              ),
              itemCount: songs.length,
              itemExtent: 72.0,
              itemBuilder: (context, index) {
                final song = songs[index];
                final baseIndex = baseSongs.indexWhere((s) => s.id == song.id);

                return SongListTile(
                  song: song,
                  index: baseIndex != -1 ? baseIndex : index,
                  playlist: baseSongs.isNotEmpty ? baseSongs : songs,
                );
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          ),
          error: (e, s) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Error al cargar música',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Removed legacy _GlassSongTile and _WaveAnimation. Replaced by global SongListTile and shared logic.

class _PlaylistsTabView extends StatelessWidget {
  const _PlaylistsTabView();

  @override
  Widget build(BuildContext context) {
    return const PlaylistsScreen();
  }
}

class _FavoritesTab extends StatefulWidget {
  const _FavoritesTab();

  @override
  State<_FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<_FavoritesTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer(
      builder: (context, ref, child) {
        final favoritesAsync = ref.watch(favoritesStreamProvider);
        final allSongsAsync = ref.watch(songsProvider);

        return favoritesAsync.when(
          data: (favoriteIds) {
            if (favoriteIds.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 80,
                      color: Colors.white24,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Aún no hay favoritos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pulsa el corazón para añadir canciones',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ],
                ),
              );
            }
            return allSongsAsync.when(
              data: (allSongs) {
                final favoriteSongs = allSongs
                    .where((song) => favoriteIds.contains(song.id))
                    .toList();

                if (favoriteSongs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No se han encontrado canciones favoritas',
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }

                return ListView.builder(
                  key: const PageStorageKey(
                    'favorites_list',
                  ), // Preservar scroll
                  padding: const EdgeInsets.only(
                    top: 24,
                    bottom: 120,
                    left: 16,
                    right: 16,
                  ),
                  itemCount: favoriteSongs.length,
                  itemBuilder: (context, index) {
                    final song = favoriteSongs[index];
                    return SongListTile(
                      song: song,
                      index: index,
                      playlist: favoriteSongs,
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              ),
              error: (e, s) => Center(
                child: Text(
                  'Error: $e',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          ),
          error: (e, s) => Center(
            child: Text(
              'Error: $e',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}

// Removed legacy _SonaMiniPlayer. Replaced by global SonaMiniPlayer.

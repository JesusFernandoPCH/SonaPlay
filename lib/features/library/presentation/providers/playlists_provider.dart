import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SonaPlay/features/library/data/datasources/playlists_local_datasource.dart';
import 'package:SonaPlay/features/library/data/repositories/playlists_repository_impl.dart';
import 'package:SonaPlay/features/library/domain/entities/playlist.dart';
import 'package:SonaPlay/features/library/domain/entities/song.dart';
import 'package:SonaPlay/features/library/domain/repositories/playlists_repository.dart';
import 'package:SonaPlay/features/library/domain/usecases/add_song_to_playlist.dart';
import 'package:SonaPlay/features/library/domain/usecases/create_playlist.dart';
import 'package:SonaPlay/features/library/domain/usecases/delete_playlist.dart';
import 'package:SonaPlay/features/library/domain/usecases/get_playlists.dart';
import 'package:SonaPlay/features/library/presentation/providers/library_provider.dart';

// ========== Data Layer Providers ==========

final playlistsLocalDataSourceProvider = Provider<PlaylistsLocalDataSource>((
  ref,
) {
  return PlaylistsLocalDataSource();
});

final playlistsRepositoryProvider = Provider<PlaylistsRepository>((ref) {
  final dataSource = ref.watch(playlistsLocalDataSourceProvider);
  return PlaylistsRepositoryImpl(dataSource);
});

// ========== Use Case Providers ==========

final createPlaylistUseCaseProvider = Provider<CreatePlaylist>((ref) {
  final repository = ref.watch(playlistsRepositoryProvider);
  return CreatePlaylist(repository);
});

final getPlaylistsUseCaseProvider = Provider<GetPlaylists>((ref) {
  final repository = ref.watch(playlistsRepositoryProvider);
  return GetPlaylists(repository);
});

final deletePlaylistUseCaseProvider = Provider<DeletePlaylist>((ref) {
  final repository = ref.watch(playlistsRepositoryProvider);
  return DeletePlaylist(repository);
});

final addSongToPlaylistUseCaseProvider = Provider<AddSongToPlaylist>((ref) {
  final repository = ref.watch(playlistsRepositoryProvider);
  return AddSongToPlaylist(repository);
});

// ========== State Providers ==========

/// Stream of all playlists
final playlistsStreamProvider = StreamProvider<List<Playlist>>((ref) async* {
  final getPlaylists = ref.watch(getPlaylistsUseCaseProvider);

  // Initial load
  yield await getPlaylists();

  // Listen for changes (poll every second for simplicity)
  // In production, consider using Hive's watch() for real-time updates
  await for (final _ in Stream.periodic(const Duration(seconds: 1))) {
    yield await getPlaylists();
  }
});

/// Get a specific playlist by ID
final playlistProvider = FutureProvider.family<Playlist?, String>((
  ref,
  playlistId,
) async {
  final repository = ref.watch(playlistsRepositoryProvider);
  return await repository.getPlaylist(playlistId);
});

/// Get songs for a specific playlist (excludes hidden songs) - FASE 7.2
final playlistSongsProvider = Provider.family<AsyncValue<List<Song>>, String>((
  ref,
  playlistId,
) {
  final playlistAsync = ref.watch(playlistProvider(playlistId));
  final allSongsAsync = ref.watch(visibleSongsProvider);

  return playlistAsync.when(
    data: (playlist) {
      if (playlist == null) {
        return const AsyncValue.data([]);
      }
      return allSongsAsync.whenData((songs) {
        return songs
            .where((song) => playlist.songIds.contains(song.id))
            .toList();
      });
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Controller for playlist operations
final playlistsControllerProvider = Provider<PlaylistsController>((ref) {
  return PlaylistsController(ref);
});

class PlaylistsController {
  final Ref _ref;

  PlaylistsController(this._ref);

  /// Create a new playlist
  Future<Playlist> createPlaylist(String name) async {
    final createUseCase = _ref.read(createPlaylistUseCaseProvider);
    final playlist = await createUseCase(name);

    // Invalidate to refresh UI
    _ref.invalidate(playlistsStreamProvider);

    return playlist;
  }

  /// Delete a playlist
  Future<void> deletePlaylist(String playlistId) async {
    final deleteUseCase = _ref.read(deletePlaylistUseCaseProvider);
    await deleteUseCase(playlistId);

    // Invalidate to refresh UI
    _ref.invalidate(playlistsStreamProvider);
    _ref.invalidate(playlistProvider(playlistId));
  }

  /// Add a song to a playlist
  /// Returns true if song was added, false if it already exists (duplicate)
  Future<bool> addSongToPlaylist(String playlistId, String songId) async {
    final addSongUseCase = _ref.read(addSongToPlaylistUseCaseProvider);
    final success = await addSongUseCase(playlistId, songId);

    // Invalidate to refresh UI
    _ref.invalidate(playlistsStreamProvider);
    _ref.invalidate(playlistProvider(playlistId));

    return success;
  }

  /// Rename a playlist
  Future<void> renamePlaylist(String playlistId, String newName) async {
    final repository = _ref.read(playlistsRepositoryProvider);
    final playlist = await repository.getPlaylist(playlistId);

    if (playlist != null) {
      final updated = playlist.copyWith(
        name: newName,
        updatedAt: DateTime.now(),
      );
      await repository.updatePlaylist(updated);

      // Invalidate to refresh UI
      _ref.invalidate(playlistsStreamProvider);
      _ref.invalidate(playlistProvider(playlistId));
    }
  }

  /// Remove a song from a playlist
  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final repository = _ref.read(playlistsRepositoryProvider);
    await repository.removeSongFromPlaylist(playlistId, songId);

    // Invalidate to refresh UI
    _ref.invalidate(playlistsStreamProvider);
    _ref.invalidate(playlistProvider(playlistId));
  }

  /// Reorder songs in a playlist
  Future<void> reorderSongs(String playlistId, List<String> newSongIds) async {
    final repository = _ref.read(playlistsRepositoryProvider);
    await repository.reorderSongs(playlistId, newSongIds);

    // Invalidate to refresh UI
    _ref.invalidate(playlistProvider(playlistId));
  }
}

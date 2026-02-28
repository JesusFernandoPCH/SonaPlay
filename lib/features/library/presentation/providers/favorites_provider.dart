import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SonaPlay/features/library/data/datasources/favorites_local_datasource.dart';
import 'package:SonaPlay/features/library/data/repositories/favorites_repository_impl.dart';
import 'package:SonaPlay/features/library/domain/entities/song.dart';
import 'package:SonaPlay/features/library/domain/repositories/favorites_repository.dart';
import 'package:SonaPlay/features/library/domain/usecases/get_favorites.dart';
import 'package:SonaPlay/features/library/domain/usecases/is_favorite.dart';
import 'package:SonaPlay/features/library/domain/usecases/toggle_favorite.dart';
import 'package:SonaPlay/features/library/presentation/providers/library_provider.dart';

// ========== Data Layer Providers ==========

final favoritesLocalDataSourceProvider = Provider<FavoritesLocalDataSource>((
  ref,
) {
  return FavoritesLocalDataSource();
});

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  final dataSource = ref.watch(favoritesLocalDataSourceProvider);
  return FavoritesRepositoryImpl(dataSource);
});

// ========== Use Case Providers ==========

final toggleFavoriteUseCaseProvider = Provider<ToggleFavorite>((ref) {
  final repository = ref.watch(favoritesRepositoryProvider);
  return ToggleFavorite(repository);
});

final getFavoritesUseCaseProvider = Provider<GetFavorites>((ref) {
  final repository = ref.watch(favoritesRepositoryProvider);
  return GetFavorites(repository);
});

final isFavoriteUseCaseProvider = Provider<IsFavorite>((ref) {
  final repository = ref.watch(favoritesRepositoryProvider);
  return IsFavorite(repository);
});

// ========== State Providers ==========

/// Stream of all favorite song IDs
final favoritesStreamProvider = StreamProvider<List<String>>((ref) async* {
  final getFavorites = ref.watch(getFavoritesUseCaseProvider);

  // Initial load
  yield await getFavorites();

  // Listen for changes (poll every second for simplicity)
  // In production, consider using Hive's watch() for real-time updates
  await for (final _ in Stream.periodic(const Duration(seconds: 1))) {
    yield await getFavorites();
  }
});

/// Visible favorite songs (excludes hidden songs) - FASE 7.2
final visibleFavoriteSongsProvider = Provider<AsyncValue<List<Song>>>((ref) {
  final allSongsAsync = ref.watch(visibleSongsProvider);
  final favoriteIdsAsync = ref.watch(favoritesStreamProvider);

  return favoriteIdsAsync.when(
    data: (favoriteIds) {
      return allSongsAsync.whenData((songs) {
        return songs.where((song) => favoriteIds.contains(song.id)).toList();
      });
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Check if a specific song is favorited
final isFavoriteProvider = FutureProvider.family<bool, String>((
  ref,
  songId,
) async {
  final isFavorite = ref.watch(isFavoriteUseCaseProvider);
  return await isFavorite(songId);
});

/// Controller for toggling favorites
final favoritesControllerProvider = Provider<FavoritesController>((ref) {
  return FavoritesController(ref);
});

class FavoritesController {
  final Ref _ref;

  FavoritesController(this._ref);

  /// Toggle favorite status for a song
  Future<void> toggleFavorite(String songId) async {
    final toggleUseCase = _ref.read(toggleFavoriteUseCaseProvider);
    await toggleUseCase(songId);

    // Invalidate providers to refresh UI
    _ref.invalidate(favoritesStreamProvider);
    _ref.invalidate(isFavoriteProvider(songId));
  }
}

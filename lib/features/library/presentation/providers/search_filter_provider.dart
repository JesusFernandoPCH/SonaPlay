import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SonaPlay/features/library/domain/entities/song.dart';
import 'package:SonaPlay/features/library/presentation/providers/library_provider.dart';
import 'package:SonaPlay/features/player/data/datasources/playback_persistence_datasource.dart';

final playbackPersistenceProvider = Provider<PlaybackPersistenceDataSource>((
  ref,
) {
  return PlaybackPersistenceDataSource();
});

// ========== Search State ==========

/// Current search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// ========== Filter States ==========

class FilterNotifier<T> extends StateNotifier<T> {
  final Future<void> Function(T) _save;

  FilterNotifier(super.initialValue, this._save);

  void update(T value) {
    state = value;
    _save(value);
  }
}

/// Selected artist filter
final selectedArtistProvider =
    StateNotifierProvider<FilterNotifier<String?>, String?>((ref) {
      final persistence = ref.watch(playbackPersistenceProvider);
      return FilterNotifier<String?>(
        persistence.selectedArtist,
        (val) => persistence.setSelectedArtist(val),
      );
    });

/// Selected album filter
final selectedAlbumProvider =
    StateNotifierProvider<FilterNotifier<String?>, String?>((ref) {
      final persistence = ref.watch(playbackPersistenceProvider);
      return FilterNotifier<String?>(
        persistence.selectedAlbum,
        (val) => persistence.setSelectedAlbum(val),
      );
    });

// ========== Sort State ==========

/// Available sort options
enum SortOption {
  titleAsc,
  titleDesc,
  artistAsc,
  artistDesc,
  albumAsc,
  albumDesc,
  durationAsc,
  durationDesc,
  dateAddedAsc,
  dateAddedDesc,
}

/// Current sort option
final sortOptionProvider =
    StateNotifierProvider<FilterNotifier<SortOption>, SortOption>((ref) {
      final persistence = ref.watch(playbackPersistenceProvider);
      return FilterNotifier<SortOption>(
        persistence.sortOption,
        (val) => persistence.setSortOption(val),
      );
    });

// ========== Computed Providers ==========

/// Base filtered and sorted songs (Artist, Album, Sort) without search query.
/// This represents the "Full Context" for playback.
final baseFilteredSongsProvider = Provider<AsyncValue<List<Song>>>((ref) {
  final songsAsync = ref.watch(visibleSongsProvider);
  final selectedArtist = ref.watch(selectedArtistProvider);
  final selectedAlbum = ref.watch(selectedAlbumProvider);
  final sortOption = ref.watch(sortOptionProvider);

  return songsAsync.whenData((songs) {
    var filtered = songs;

    // Apply artist filter
    if (selectedArtist != null) {
      filtered = filtered.where((s) => s.artist == selectedArtist).toList();
    }

    // Apply album filter
    if (selectedAlbum != null) {
      filtered = filtered.where((s) => s.album == selectedAlbum).toList();
    }

    // Apply sorting
    filtered = _sortSongs(filtered, sortOption);

    return filtered;
  });
});

/// Final filtered songs including the search query.
/// This represents the "View Context" for display in Search screen.
final filteredSongsProvider = Provider<AsyncValue<List<Song>>>((ref) {
  final songsAsync = ref.watch(baseFilteredSongsProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  return songsAsync.whenData((songs) {
    if (searchQuery.isEmpty) return songs;

    final query = searchQuery.toLowerCase();
    return songs.where((song) {
      return song.title.toLowerCase().contains(query) ||
          song.artist.toLowerCase().contains(query) ||
          (song.album?.toLowerCase().contains(query) ?? false);
    }).toList();
  });
});

/// Get list of unique artists from all songs
final uniqueArtistsProvider = Provider<List<String>>((ref) {
  final songsAsync = ref.watch(songsProvider);
  return songsAsync.maybeWhen(
    data: (songs) {
      final artists = songs.map((s) => s.artist).toSet().toList();
      artists.sort();
      return artists;
    },
    orElse: () => [],
  );
});

/// Get list of unique albums from all songs
final uniqueAlbumsProvider = Provider<List<String>>((ref) {
  final songsAsync = ref.watch(songsProvider);
  return songsAsync.maybeWhen(
    data: (songs) {
      final albums = songs
          .where((s) => s.album != null && s.album!.isNotEmpty)
          .map((s) => s.album!)
          .toSet()
          .toList();
      albums.sort();
      return albums;
    },
    orElse: () => [],
  );
});

// ========== Helper Functions ==========

/// Sort songs based on selected option
List<Song> _sortSongs(List<Song> songs, SortOption option) {
  final sorted = List<Song>.from(songs);

  switch (option) {
    case SortOption.titleAsc:
      sorted.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
      break;
    case SortOption.titleDesc:
      sorted.sort(
        (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
      );
      break;
    case SortOption.artistAsc:
      sorted.sort(
        (a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()),
      );
      break;
    case SortOption.artistDesc:
      sorted.sort(
        (a, b) => b.artist.toLowerCase().compareTo(a.artist.toLowerCase()),
      );
      break;
    case SortOption.albumAsc:
      sorted.sort((a, b) {
        final albumA = a.album ?? '';
        final albumB = b.album ?? '';
        return albumA.toLowerCase().compareTo(albumB.toLowerCase());
      });
      break;
    case SortOption.albumDesc:
      sorted.sort((a, b) {
        final albumA = a.album ?? '';
        final albumB = b.album ?? '';
        return albumB.toLowerCase().compareTo(albumA.toLowerCase());
      });
      break;
    case SortOption.durationAsc:
      sorted.sort((a, b) => (a.duration ?? 0).compareTo(b.duration ?? 0));
      break;
    case SortOption.durationDesc:
      sorted.sort((a, b) => (b.duration ?? 0).compareTo(a.duration ?? 0));
      break;
    case SortOption.dateAddedAsc:
      sorted.sort((a, b) => (a.dateAdded ?? 0).compareTo(b.dateAdded ?? 0));
      break;
    case SortOption.dateAddedDesc:
      sorted.sort((a, b) => (b.dateAdded ?? 0).compareTo(a.dateAdded ?? 0));
      break;
  }

  return sorted;
}

/// Get human-readable label for sort option
String getSortLabel(SortOption option) {
  switch (option) {
    case SortOption.titleAsc:
      return 'Titulo (A-Z)';
    case SortOption.titleDesc:
      return 'Titulo (Z-A)';
    case SortOption.artistAsc:
      return 'Artista (A-Z)';
    case SortOption.artistDesc:
      return 'Artista (Z-A)';
    case SortOption.albumAsc:
      return 'Album (A-Z)';
    case SortOption.albumDesc:
      return 'Album (Z-A)';
    case SortOption.durationAsc:
      return 'Duración (Más corto)';
    case SortOption.durationDesc:
      return 'Duración (Más largo)';
    case SortOption.dateAddedAsc:
      return 'Fecha (Más antiguo)';
    case SortOption.dateAddedDesc:
      return 'Fecha (Más reciente)';
  }
}

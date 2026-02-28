import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SonaPlay/features/library/data/datasources/local_music_datasource.dart';
import 'package:SonaPlay/features/library/data/datasources/metadata_persistence_datasource.dart';
import 'package:SonaPlay/features/library/data/datasources/songs_persistence_datasource.dart';
import 'package:SonaPlay/features/library/data/repositories/library_repository_impl.dart';
import 'package:SonaPlay/features/library/domain/entities/song.dart';
import 'package:SonaPlay/features/library/domain/usecases/get_all_songs.dart';
import 'package:SonaPlay/features/library/presentation/providers/hidden_songs_provider.dart';
import 'package:SonaPlay/features/library/presentation/providers/deleted_songs_provider.dart';

/// Data source provider
final localMusicDataSourceProvider = Provider<LocalMusicDataSource>((ref) {
  return LocalMusicDataSource();
});

final songsPersistenceDataSourceProvider = Provider<SongsPersistenceDataSource>(
  (ref) {
    return SongsPersistenceDataSource();
  },
);

final metadataPersistenceDataSourceProvider =
    Provider<MetadataPersistenceDataSource>((ref) {
      return MetadataPersistenceDataSource();
    });

/// Repository provider
final libraryRepositoryProvider = Provider<LibraryRepositoryImpl>((ref) {
  final dataSource = ref.watch(localMusicDataSourceProvider);
  final metadataDataSource = ref.watch(metadataPersistenceDataSourceProvider);
  return LibraryRepositoryImpl(dataSource, metadataDataSource);
});

/// Use case provider
final getAllSongsUseCaseProvider = Provider<GetAllSongs>((ref) {
  final repository = ref.watch(libraryRepositoryProvider);
  return GetAllSongs(repository);
});

/// Songs list provider (Reactive Stream)
final songsProvider = StreamProvider<List<Song>>((ref) {
  final useCase = ref.watch(getAllSongsUseCaseProvider);
  return useCase();
});

/// Visible songs provider - filters out hidden songs (FASE 7.2)
final visibleSongsProvider = Provider<AsyncValue<List<Song>>>((ref) {
  final songsAsync = ref.watch(songsProvider);
  final hiddenIds = ref.watch(hiddenSongsStreamProvider).value ?? [];
  final deletedIds = ref.watch(deletedSongsStreamProvider).value ?? [];

  return songsAsync.whenData((songs) {
    return songs.where((song) {
      final isHidden = hiddenIds.contains(song.id);
      final isDeleted = deletedIds.contains(song.id);
      return !isHidden && !isDeleted;
    }).toList();
  });
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SonaPlay/features/library/data/datasources/hidden_songs_local_datasource.dart';
import 'package:SonaPlay/features/library/data/repositories/hidden_songs_repository_impl.dart';
import 'package:SonaPlay/features/library/domain/usecases/get_hidden_songs.dart';
import 'package:SonaPlay/features/library/domain/usecases/hide_song.dart';
import 'package:SonaPlay/features/library/domain/usecases/unhide_song.dart';

/// Data source provider
final hiddenSongsDataSourceProvider = Provider<HiddenSongsLocalDataSource>((
  ref,
) {
  return HiddenSongsLocalDataSource();
});

/// Repository provider
final hiddenSongsRepositoryProvider = Provider<HiddenSongsRepositoryImpl>((
  ref,
) {
  final dataSource = ref.watch(hiddenSongsDataSourceProvider);
  return HiddenSongsRepositoryImpl(dataSource);
});

/// Use case providers
final getHiddenSongsUseCaseProvider = Provider<GetHiddenSongs>((ref) {
  final repository = ref.watch(hiddenSongsRepositoryProvider);
  return GetHiddenSongs(repository);
});

final hideSongUseCaseProvider = Provider<HideSong>((ref) {
  final repository = ref.watch(hiddenSongsRepositoryProvider);
  return HideSong(repository);
});

final unhideSongUseCaseProvider = Provider<UnhideSong>((ref) {
  final repository = ref.watch(hiddenSongsRepositoryProvider);
  return UnhideSong(repository);
});

/// Stream provider for hidden song IDs
final hiddenSongsStreamProvider = StreamProvider<List<String>>((ref) {
  final useCase = ref.watch(getHiddenSongsUseCaseProvider);
  return useCase.watch();
});

/// Check if a specific song is hidden
final isSongHiddenProvider = Provider.family<bool, String>((ref, songId) {
  final hiddenSongs = ref.watch(hiddenSongsStreamProvider).value ?? [];
  return hiddenSongs.contains(songId);
});

/// Controller for hidden songs actions
final hiddenSongsControllerProvider = Provider<HiddenSongsController>((ref) {
  final hideSongUseCase = ref.watch(hideSongUseCaseProvider);
  final unhideSongUseCase = ref.watch(unhideSongUseCaseProvider);
  return HiddenSongsController(hideSongUseCase, unhideSongUseCase);
});

/// Controller class for hidden songs
class HiddenSongsController {
  final HideSong _hideSongUseCase;
  final UnhideSong _unhideSongUseCase;

  HiddenSongsController(this._hideSongUseCase, this._unhideSongUseCase);

  Future<void> hideSong(String songId) async {
    await _hideSongUseCase(songId);
  }

  Future<void> unhideSong(String songId) async {
    await _unhideSongUseCase(songId);
  }
}

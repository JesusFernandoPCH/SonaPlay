import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SonaPlay/features/library/data/datasources/deleted_songs_local_datasource.dart';

final deletedSongsDataSourceProvider = Provider<DeletedSongsLocalDataSource>((
  ref,
) {
  return DeletedSongsLocalDataSource();
});

final deletedSongsStreamProvider = StreamProvider<List<String>>((ref) {
  final dataSource = ref.watch(deletedSongsDataSourceProvider);
  return dataSource.watchDeletedSongs();
});

final deletedSongsControllerProvider = Provider<DeletedSongsController>((ref) {
  final dataSource = ref.watch(deletedSongsDataSourceProvider);
  return DeletedSongsController(dataSource, ref);
});

class DeletedSongsController {
  final DeletedSongsLocalDataSource _dataSource;
  final Ref _ref;

  DeletedSongsController(this._dataSource, this._ref);

  Future<void> softDeleteSong(String songId) async {
    await _dataSource.softDeleteSong(songId);
    _ref.invalidate(deletedSongsStreamProvider);
  }

  Future<void> restoreSong(String songId) async {
    await _dataSource.restoreSong(songId);
    _ref.invalidate(deletedSongsStreamProvider);
  }
}

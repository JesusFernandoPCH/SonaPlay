import 'package:SonaPlay/features/library/domain/entities/playlist.dart';
import 'package:SonaPlay/features/library/domain/repositories/playlists_repository.dart';

/// Use case for getting all playlists
class GetPlaylists {
  final PlaylistsRepository _repository;

  GetPlaylists(this._repository);

  Future<List<Playlist>> call() async {
    return await _repository.getAllPlaylists();
  }
}

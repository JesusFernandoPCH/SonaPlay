import 'package:shared_preferences/shared_preferences.dart';

class DeletedSongsLocalDataSource {
  static const String _key = 'deleted_songs_ids';

  Future<List<String>> getDeletedSongIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  Future<void> softDeleteSong(String songId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? [];
    if (!current.contains(songId)) {
      current.add(songId);
      await prefs.setStringList(_key, current);
    }
  }

  Future<void> restoreSong(String songId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? [];
    if (current.contains(songId)) {
      current.remove(songId);
      await prefs.setStringList(_key, current);
    }
  }

  Stream<List<String>> watchDeletedSongs() async* {
    // Basic implementation using a periodic check or specialized stream if needed
    // For now, let's keep it simple with SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    yield prefs.getStringList(_key) ?? [];
  }
}

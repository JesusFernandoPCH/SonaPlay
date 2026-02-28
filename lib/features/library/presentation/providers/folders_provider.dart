import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SonaPlay/features/library/domain/entities/folder.dart';
import 'package:SonaPlay/features/library/domain/entities/song.dart';
import 'package:SonaPlay/features/library/presentation/providers/library_provider.dart';

/// Provider that groups songs into folders based on their directory path
final foldersProvider = Provider<AsyncValue<List<Folder>>>((ref) {
  final songsAsync = ref.watch(songsProvider);

  return songsAsync.whenData((songs) {
    if (songs.isEmpty) return [];

    final Map<String, List<Song>> folderGroups = {};

    for (final song in songs) {
      final path = song.filePath;
      final lastSeparator = path.lastIndexOf('/');
      if (lastSeparator == -1) continue;

      final folderPath = path.substring(0, lastSeparator);

      if (!folderGroups.containsKey(folderPath)) {
        folderGroups[folderPath] = [];
      }
      folderGroups[folderPath]!.add(song);
    }

    final List<Folder> folders = folderGroups.entries.map((entry) {
      final path = entry.key;
      final name = path.substring(path.lastIndexOf('/') + 1);

      return Folder(
        path: path,
        name: name.isEmpty ? 'Root' : name,
        songs: entry.value,
      );
    }).toList();

    // Sort folders alphabetically by name
    folders.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

    return folders;
  });
});

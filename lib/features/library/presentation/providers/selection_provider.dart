import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SonaPlay/features/library/domain/entities/song.dart';

/// Selection state for multi-select mode
class SelectionState {
  final Set<String> selectedSongIds;
  final bool isSelectionMode;

  const SelectionState({
    this.selectedSongIds = const {},
    this.isSelectionMode = false,
  });

  SelectionState copyWith({
    Set<String>? selectedSongIds,
    bool? isSelectionMode,
  }) {
    return SelectionState(
      selectedSongIds: selectedSongIds ?? this.selectedSongIds,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
    );
  }

  bool isSelected(String songId) => selectedSongIds.contains(songId);
  int get selectedCount => selectedSongIds.length;

  List<Song> getSelectedSongs(List<Song> allSongs) {
    return allSongs.where((song) => selectedSongIds.contains(song.id)).toList();
  }
}

/// Selection controller for multi-select mode
class SelectionController extends StateNotifier<SelectionState> {
  SelectionController() : super(const SelectionState());

  void enterSelectionMode(String initialSongId) {
    state = SelectionState(
      selectedSongIds: {initialSongId},
      isSelectionMode: true,
    );
  }

  void toggleSelection(String songId) {
    final newSelection = Set<String>.from(state.selectedSongIds);
    if (newSelection.contains(songId)) {
      newSelection.remove(songId);
    } else {
      newSelection.add(songId);
    }

    // Exit selection mode if no items selected
    if (newSelection.isEmpty) {
      exitSelectionMode();
    } else {
      state = state.copyWith(selectedSongIds: newSelection);
    }
  }

  void exitSelectionMode() {
    state = const SelectionState();
  }

  void selectAll(List<String> songIds) {
    state = state.copyWith(selectedSongIds: Set<String>.from(songIds));
  }
}

/// Selection controller provider
final selectionControllerProvider =
    StateNotifierProvider<SelectionController, SelectionState>((ref) {
      return SelectionController();
    });

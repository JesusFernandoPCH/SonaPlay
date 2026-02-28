import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SonaPlay/features/library/domain/entities/song.dart';
import 'package:SonaPlay/features/player/data/services/audio_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:SonaPlay/features/player/domain/entities/player_state.dart';
import 'package:SonaPlay/main.dart';

// ========== AUDIO HANDLER PROVIDER ==========

/// AudioHandler provider (from main.dart global instance)
final audioHandlerProvider = Provider((ref) => audioHandler);

// ========== STREAM PROVIDERS FROM AUDIO HANDLER ==========

/// Media item stream provider (current song from notification)
final _mediaItemStreamProvider = StreamProvider((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.mediaItem;
});

/// Playback state stream provider (from AudioService)
final _playbackStateStreamProvider = StreamProvider((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.playbackState;
});

// ========== CURRENT SONG PROVIDERS ==========

/// Current song provider (from AudioPlayerDataSource for full metadata)
final currentSongProvider = StreamProvider<Song?>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.audioPlayer.currentSongStream;
});

/// Current song ID provider (for UI comparison)
final currentSongIdProvider = Provider<String?>((ref) {
  final currentSong = ref.watch(currentSongProvider);
  return currentSong.maybeWhen(data: (song) => song?.id, orElse: () => null);
});

/// Has current song provider (for showing/hiding mini player)
final hasCurrentSongProvider = Provider<bool>((ref) {
  final currentSong = ref.watch(currentSongProvider);
  return currentSong.maybeWhen(
    data: (song) => song != null,
    orElse: () => false,
  );
});

// ========== PLAYBACK STATE PROVIDERS ==========

/// Is playing provider
final isPlayingProvider = Provider<bool>((ref) {
  final playbackState = ref.watch(_playbackStateStreamProvider);
  return playbackState.maybeWhen(
    data: (state) => state.playing,
    orElse: () => false,
  );
});

/// Position provider (for progress bar)
final positionProvider = Provider<Duration>((ref) {
  final playbackState = ref.watch(_playbackStateStreamProvider);
  return playbackState.maybeWhen(
    data: (state) => state.updatePosition,
    orElse: () => Duration.zero,
  );
});

/// Duration provider (for progress bar)
final durationProvider = Provider<Duration>((ref) {
  final mediaItem = ref.watch(_mediaItemStreamProvider);
  return mediaItem.maybeWhen(
    data: (item) => item?.duration ?? Duration.zero,
    orElse: () => Duration.zero,
  );
});

// ========== PLAYER STATE PROVIDERS (from AudioPlayerDataSource) ==========
// We still need these for shuffle/repeat state since AudioService doesn't track them

/// Internal player state stream (from AudioPlayerDataSource)
final _playerStateStreamProvider = StreamProvider<PlayerState>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  // Access the public AudioPlayerDataSource stream
  return handler.audioPlayer.playerStateStream;
});

/// Repeat mode provider
final repeatModeProvider = Provider<RepeatMode>((ref) {
  final playerState = ref.watch(_playerStateStreamProvider);
  return playerState.maybeWhen(
    data: (state) => state.repeatMode,
    orElse: () => RepeatMode.all,
  );
});

/// Shuffle provider
final isShuffledProvider = Provider<bool>((ref) {
  final playerState = ref.watch(_playerStateStreamProvider);
  return playerState.maybeWhen(
    data: (state) => state.isShuffled,
    orElse: () => false,
  );
});

// ========== AUDIO CONTROLS ==========

/// Audio controls provider (wraps AudioHandler methods)
final audioControlsProvider = Provider((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return AudioController(handler);
});

/// Audio controller for playback actions
class AudioController {
  final SonaPlayAudioHandler _handler;

  AudioController(this._handler);

  Future<void> play(Song song, List<Song> playlist, int index) async {
    // Optimization: If the playlist is the same as the current queue, just skip to index
    // This avoids re-shuffling when selecting from the queue screen
    final currentQueue = _handler.audioPlayer.currentPlaylist;
    if (listEquals(currentQueue, playlist)) {
      await _handler.skipToIndex(index);
    } else {
      await _handler.playSong(song, playlist, index);
    }
  }

  Future<void> skipToIndex(int index) async {
    await _handler.skipToIndex(index);
  }

  Future<void> playPause() async {
    final handler = _handler;
    final isPlaying = await handler.audioPlayer.playerStateStream.first.then(
      (s) => s.isPlaying,
    );
    if (isPlaying) {
      await handler.pause();
    } else {
      await handler.play();
    }
  }

  Future<void> pause() async {
    await _handler.pause();
  }

  Future<void> resume() async {
    await _handler.play();
  }

  Future<void> skipToNext() async {
    await _handler.skipToNext();
  }

  Future<void> skipToPrevious() async {
    await _handler.skipToPrevious();
  }

  Future<void> seek(Duration position) async {
    await _handler.seek(position);
  }

  Future<void> toggleShuffle() async {
    await _handler.audioPlayer.toggleShuffle();
  }

  Future<void> toggleRepeat() async {
    final currentMode = await _handler.audioPlayer.playerStateStream.first.then(
      (s) => s.repeatMode,
    );
    final newMode = currentMode == RepeatMode.all
        ? RepeatMode.one
        : RepeatMode.all;
    await _handler.audioPlayer.setRepeatMode(newMode);
  }

  Future<void> setRepeatMode(RepeatMode mode) async {
    await _handler.audioPlayer.setRepeatMode(mode);
  }

  Future<void> stop() async {
    await _handler.stop();
  }

  // FASE 7.2: Queue management
  Future<void> playNext(Song song) async {
    await _handler.playNext(song);
  }

  Future<void> reorderQueue(int oldIndex, int newIndex) async {
    await _handler.audioPlayer.reorderQueue(oldIndex, newIndex);
  }

  Future<void> setSpeed(double speed) async {
    await _handler.audioPlayer.setSpeed(speed);
  }
}

// ========== QUEUE PROVIDERS (FASE 7.2) ==========

/// Current queue provider
final currentQueueProvider = Provider<List<Song>>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  // Watch player state to trigger rebuilds when queue changes
  ref.watch(_playerStateStreamProvider);
  return handler.audioPlayer.currentPlaylist;
});

/// Current index provider
final currentIndexProvider = Provider<int?>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  // Watch player state to trigger rebuilds when index changes
  ref.watch(_playerStateStreamProvider);
  return handler.audioPlayer.currentIndex;
});

/// Play song use case provider (for compatibility with existing code)
final playSongUseCaseProvider = Provider((ref) {
  final controller = ref.watch(audioControlsProvider);
  return (Song song, List<Song> playlist, int index) async {
    await controller.play(song, playlist, index);
  };
});

/// Audio controller provider (alias for audioControlsProvider)
final audioControllerProvider = audioControlsProvider;

/// Play song use case wrapper
class PlaySongUseCase {
  final AudioController _controls;

  PlaySongUseCase(this._controls);

  Future<void> call(
    Song song, {
    required List<Song> playlist,
    required int index,
  }) {
    return _controls.play(song, playlist, index);
  }
}

/// Control playback use case provider (for compatibility)
final controlPlaybackUseCaseProvider = Provider((ref) {
  return ref.watch(audioControlsProvider);
});

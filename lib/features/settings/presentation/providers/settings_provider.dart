import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/settings_local_datasource.dart';

class SettingsState {
  final bool oledMode;
  final double glassIntensity;
  final int minDuration;
  final String artworkQuality;
  final int accentColor;

  SettingsState({
    required this.oledMode,
    required this.glassIntensity,
    required this.minDuration,
    required this.artworkQuality,
    required this.accentColor,
  });

  SettingsState copyWith({
    bool? oledMode,
    double? glassIntensity,
    int? minDuration,
    String? artworkQuality,
    int? accentColor,
  }) {
    return SettingsState(
      oledMode: oledMode ?? this.oledMode,
      glassIntensity: glassIntensity ?? this.glassIntensity,
      minDuration: minDuration ?? this.minDuration,
      artworkQuality: artworkQuality ?? this.artworkQuality,
      accentColor: accentColor ?? this.accentColor,
    );
  }
}

final settingsLocalDataSourceProvider = Provider<SettingsLocalDataSource>((
  ref,
) {
  return SettingsLocalDataSource();
});

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SettingsLocalDataSource _dataSource;

  SettingsNotifier(this._dataSource)
    : super(
        SettingsState(
          oledMode: _dataSource.oledMode,
          glassIntensity: _dataSource.glassIntensity,
          minDuration: _dataSource.minDuration,
          artworkQuality: _dataSource.artworkQuality,
          accentColor: _dataSource.accentColor,
        ),
      );

  Future<void> toggleOledMode(bool value) async {
    await _dataSource.setOledMode(value);
    state = state.copyWith(oledMode: value);
  }

  Future<void> setGlassIntensity(double value) async {
    await _dataSource.setGlassIntensity(value);
    state = state.copyWith(glassIntensity: value);
  }

  Future<void> setMinDuration(int value) async {
    await _dataSource.setMinDuration(value);
    state = state.copyWith(minDuration: value);
  }

  Future<void> setArtworkQuality(String value) async {
    await _dataSource.setArtworkQuality(value);
    state = state.copyWith(artworkQuality: value);
  }

  Future<void> setAccentColor(int value) async {
    await _dataSource.setAccentColor(value);
    state = state.copyWith(accentColor: value);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    final dataSource = ref.watch(settingsLocalDataSourceProvider);
    return SettingsNotifier(dataSource);
  },
);

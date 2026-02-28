import 'dart:ui';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:SonaPlay/app.dart';
import 'package:SonaPlay/features/library/data/models/favorite_model.dart';
import 'package:SonaPlay/features/library/data/models/hidden_songs_model.dart';
import 'package:SonaPlay/features/library/data/models/playlist_model.dart';
import 'package:SonaPlay/features/library/data/models/song_model.dart';
import 'package:SonaPlay/features/player/data/datasources/audio_player_datasource.dart';
import 'package:SonaPlay/features/player/data/datasources/playback_persistence_datasource.dart';
import 'package:SonaPlay/features/player/data/services/audio_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:SonaPlay/core/services/update_service.dart';
import 'package:SonaPlay/core/widgets/forced_update_dialog.dart';
import 'package:SonaPlay/firebase_options.dart';

/// Global AudioHandler instance
late SonaPlayAudioHandler audioHandler;

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Initialize Update Service
  final updateService = UpdateService();
  await updateService.initialize();
  final isUpdateRequired = await updateService.isUpdateRequired();

  // Initialize Hive for local storage (FASE 6 + 7.2)
  await Hive.initFlutter();
  Hive.registerAdapter(FavoriteModelAdapter());
  Hive.registerAdapter(PlaylistModelAdapter());
  Hive.registerAdapter(HiddenSongsModelAdapter()); // FASE 7.2
  Hive.registerAdapter(SongModelAdapter()); // Performance Optimization
  await Hive.openBox<FavoriteModel>('favorites');
  await Hive.openBox<PlaylistModel>('playlists');
  await Hive.openBox<SongModel>('cached_songs');
  await Hive.openBox('settings_box');
  await Hive.openBox('playback_settings_box');

  // Initialize AudioHandler BEFORE runApp
  // This creates a foreground service that survives app removal from Recents
  final playbackPersistence = PlaybackPersistenceDataSource();
  audioHandler = await AudioService.init(
    builder: () =>
        SonaPlayAudioHandler(AudioPlayerDataSource(playbackPersistence)),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.sonaplay.audio',
      androidNotificationChannelName: 'SonaPlay',
      androidNotificationOngoing: true, // Persistent notification
      androidStopForegroundOnPause:
          true, // REQUIRED when androidNotificationOngoing=true
      androidNotificationIcon: 'drawable/ic_notification',
      fastForwardInterval: Duration(seconds: 10),
      rewindInterval: Duration(seconds: 10),
    ),
  );

  // Set system UI overlay style (status bar, navigation bar)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.black,
    ),
  );

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Run app
  runApp(
    ProviderScope(
      child: isUpdateRequired
          ? MaterialApp(
              home: ForcedUpdateDialog(updateUrl: updateService.updateUrl),
              debugShowCheckedModeBanner: false,
            )
          : const SonaPlayApp(),
    ),
  );
}

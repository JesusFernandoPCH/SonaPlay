import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:SonaPlay/features/player/presentation/providers/audio_provider.dart';

final paletteProvider = FutureProvider.autoDispose<PaletteGenerator?>((
  ref,
) async {
  final currentSong = ref.watch(currentSongProvider).value;
  if (currentSong == null) return null;

  ImageProvider? imageProvider;

  final String? artworkPath = currentSong.artworkPath;
  if (artworkPath != null && artworkPath.isNotEmpty) {
    final file = File(artworkPath);
    if (await file.exists()) {
      imageProvider = FileImage(file);
    }
  }

  if (imageProvider == null) {
    // Try to get artwork from on_audio_query
    final OnAudioQuery audioQuery = OnAudioQuery();
    final Uint8List? artwork = await audioQuery.queryArtwork(
      int.parse(currentSong.id),
      ArtworkType.AUDIO,
      format: ArtworkFormat.JPEG,
      size: 200,
    );

    if (artwork != null) {
      imageProvider = MemoryImage(artwork);
    }
  }

  if (imageProvider != null) {
    return await PaletteGenerator.fromImageProvider(
      imageProvider,
      maximumColorCount: 10,
    );
  }

  return null;
});

final dominantColorProvider = Provider.autoDispose<Color>((ref) {
  final paletteAsync = ref.watch(paletteProvider);
  return paletteAsync.maybeWhen(
    data: (palette) => palette?.dominantColor?.color ?? const Color(0xFF5B13EC),
    orElse: () => const Color(0xFF5B13EC),
  );
});

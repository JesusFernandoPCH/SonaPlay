import 'dart:io';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

/// Custom artwork widget that prevents flickering during transitions
///
/// This widget wraps QueryArtworkWidget with keepOldArtwork: true to ensure
/// smooth transitions between songs without blank frames or flickering.
///
/// Based on the proven pattern from SonaPlay V2.
class CustomArtworkWidget extends StatelessWidget {
  /// The song ID to display artwork for
  final int songId;

  /// Optional path to local artwork file
  final String? artworkPath;

  /// Size of the artwork displayed in the UI
  final double size;

  /// Quality of the artwork (0-100)
  final int quality;

  /// Format of the artwork
  final ArtworkFormat format;

  /// Border radius for the artwork
  final BorderRadius? borderRadius;

  /// Box fit for the artwork
  final BoxFit fit;

  const CustomArtworkWidget({
    super.key,
    required this.songId,
    this.artworkPath,
    this.size = 56,
    this.quality = 100,
    this.format = ArtworkFormat.JPEG,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = borderRadius ?? BorderRadius.circular(4);

    if (artworkPath != null && artworkPath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: radius,
        child: Image.file(
          File(artworkPath!),
          width: size,
          height: size,
          fit: fit,
          errorBuilder: (context, error, stackTrace) =>
              _buildNullArtwork(size, radius, colorScheme),
        ),
      );
    }

    return QueryArtworkWidget(
      id: songId,
      type: ArtworkType.AUDIO,
      size: (size * 2).toInt(),
      quality: quality,
      format: format,
      artworkWidth: size,
      artworkHeight: size,
      artworkFit: fit,
      artworkBorder: radius,
      artworkQuality: FilterQuality.high,
      keepOldArtwork: true,
      nullArtworkWidget: _buildNullArtwork(size, radius, colorScheme),
    );
  }

  Widget _buildNullArtwork(
    double size,
    BorderRadius radius,
    ColorScheme colorScheme,
  ) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: radius,
      ),
      child: Icon(
        Icons.music_note,
        color: colorScheme.onSurfaceVariant,
        size: size * 0.5,
      ),
    );
  }
}

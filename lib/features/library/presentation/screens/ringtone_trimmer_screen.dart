import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:SonaPlay/core/constants/app_colors.dart';
import 'package:SonaPlay/features/player/presentation/providers/palette_provider.dart';
import 'package:SonaPlay/core/presentation/widgets/vibrant_background.dart';
import 'package:SonaPlay/services/ringtone_service.dart';

class RingtoneTrimmerScreen extends ConsumerStatefulWidget {
  final String audioPath;
  final String songTitle;

  const RingtoneTrimmerScreen({
    super.key,
    required this.audioPath,
    required this.songTitle,
  });

  @override
  ConsumerState<RingtoneTrimmerScreen> createState() =>
      _RingtoneTrimmerScreenState();
}

class _RingtoneTrimmerScreenState extends ConsumerState<RingtoneTrimmerScreen> {
  late PlayerController playerController;
  bool isPlaying = false;
  bool isLoaded = false;
  bool isProcessing = false;

  double startTime = 0.0;
  double endTime = 45.0; // Default max 45s
  double maxAudioDuration = 100.0; // Default until loaded

  final double MIN_TRIM_DURATION = 5.0;
  final double MAX_TRIM_DURATION = 45.0;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    playerController = PlayerController();

    try {
      await playerController.preparePlayer(
        path: widget.audioPath,
        shouldExtractWaveform: true,
        noOfSamples: 100,
        volume: 1.0,
      );

      final maxDurationMs = await playerController.getDuration(
        DurationType.max,
      );
      final double durationSec = maxDurationMs / 1000.0;

      playerController.onPlayerStateChanged.listen((state) {
        if (mounted) {
          setState(() {
            isPlaying = state.isPlaying;
          });
        }
      });

      playerController.onCurrentDurationChanged.listen((durationMs) async {
        final currentSec = durationMs / 1000.0;
        if (currentSec >= endTime) {
          await playerController.pausePlayer();
          await playerController.seekTo(
            int.parse((startTime * 1000).toStringAsFixed(0)),
          );
        }
      });

      if (mounted) {
        setState(() {
          maxAudioDuration = durationSec;
          endTime = durationSec > MAX_TRIM_DURATION
              ? MAX_TRIM_DURATION
              : durationSec;
          isLoaded = true;
        });
      }
    } catch (e) {
      debugPrint("Error loading waveform: $e");
    }
  }

  @override
  void dispose() {
    playerController.dispose();
    super.dispose();
  }

  void _togglePlay() async {
    if (isPlaying) {
      await playerController.pausePlayer();
    } else {
      // Si la posición actúal es mayor al endTime, regresamos al startTime
      final currentPosMs = await playerController.getDuration(
        DurationType.current,
      );
      final currentPosSec = currentPosMs / 1000.0;

      if (currentPosSec >= endTime || currentPosSec < startTime) {
        await playerController.seekTo(
          int.parse((startTime * 1000).toStringAsFixed(0)),
        );
      }
      await playerController.startPlayer();
    }
  }

  void _onRangeChanged(RangeValues values) {
    if (!mounted) return;

    double newStart = values.start;
    double newEnd = values.end;

    // Validate limits
    if (newEnd - newStart < MIN_TRIM_DURATION) {
      // Revert change
      if (newStart != startTime) {
        newStart = newEnd - MIN_TRIM_DURATION;
        if (newStart < 0) newStart = 0;
      } else {
        newEnd = newStart + MIN_TRIM_DURATION;
        if (newEnd > maxAudioDuration) newEnd = maxAudioDuration;
      }
    }

    if (newEnd - newStart > MAX_TRIM_DURATION) {
      if (newStart != startTime) {
        newStart = newEnd - MAX_TRIM_DURATION;
      } else {
        newEnd = newStart + MAX_TRIM_DURATION;
      }
    }

    setState(() {
      startTime = newStart;
      endTime = newEnd;
    });

    // Seek to new start if it changed
    playerController.seekTo(int.parse((startTime * 1000).toStringAsFixed(0)));
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = ref.watch(dominantColorProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDarkBlue,
      appBar: AppBar(
        title: const Text(
          'Crear tono de llamada',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          VibrantBackground(accentColor: accentColor),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  widget.songTitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 40),

                // WAVEFORM AND TRIMMER
                if (isLoaded)
                  _buildTrimmer(accentColor)
                else
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),

                // PLAY BUTTON
                if (isLoaded)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: GestureDetector(
                      onTap: _togglePlay,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),

                const Spacer(),

                // ACTION BUTTON
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isProcessing
                          ? null
                          : () async {
                              setState(() {
                                isProcessing = true;
                              });

                              try {
                                final success =
                                    await RingtoneService.setAsRingtone(
                                      filePath: widget.audioPath,
                                      startSeconds: startTime,
                                      endSeconds: endTime,
                                    );

                                if (success && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        '¡Tono de llamada establecido con éxito!',
                                      ),
                                    ),
                                  );
                                  Navigator.pop(context);
                                }
                              } on RingtonePermissionException {
                                if (mounted) {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      backgroundColor:
                                          AppColors.backgroundDarkBlue,
                                      title: const Text(
                                        'Permisos Necesarios',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      content: const Text(
                                        'Para poder establecer el tono de llamada, la aplicación te ha redirigido a las configuraciones para otorgar el permiso correspondiente de Android. Regresa e inténtalo de nuevo.',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text(
                                            'Entendido',
                                            style: TextStyle(
                                              color: AppColors.primaryBlue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(SnackBar(content: Text('$e')));
                                }
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    isProcessing = false;
                                  });
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.9),
                        foregroundColor: AppColors.backgroundDarkBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: isProcessing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.backgroundDarkBlue,
                              ),
                            )
                          : const Text(
                              'Establecer como tono de llamada',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrimmer(Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Waveform Base
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AudioFileWaveforms(
                size: Size(MediaQuery.of(context).size.width - 80, 80),
                playerController: playerController,
                enableSeekGesture: false,
                waveformType: WaveformType.fitWidth,
                playerWaveStyle: PlayerWaveStyle(
                  fixedWaveColor: Colors.white.withOpacity(0.3),
                  liveWaveColor: Colors.white,
                  showSeekLine: false,
                  waveThickness: 2,
                  spacing: 4,
                ),
              ),
            ),

            // Slider Overlay
            Positioned.fill(
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 120,
                  activeTrackColor: Colors.white.withOpacity(0.2),
                  inactiveTrackColor: Colors.transparent,
                  thumbColor: Colors.white,
                  overlayColor: Colors.white.withOpacity(0.1),
                  rangeThumbShape: _CustomRangeThumbShape(),
                  rangeTrackShape: _CustomRangeTrackShape(),
                ),
                child: RangeSlider(
                  min: 0.0,
                  max: maxAudioDuration,
                  values: RangeValues(startTime, endTime),
                  onChanged: _onRangeChanged,
                ),
              ),
            ),

            // Time Labels Overlay
            Positioned(
              top: 8,
              left: 16,
              child: Text(
                _formatTime(startTime),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 16,
              child: Text(
                _formatTime(endTime),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(double seconds) {
    int totalSec = seconds.toInt();
    int min = totalSec ~/ 60;
    int sec = totalSec % 60;
    return '${min.toString()}:${sec.toString().padLeft(2, '0')}';
  }
}

class _CustomRangeTrackShape extends RangeSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 120;
    final double trackLeft = offset.dx + 16;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width - 32;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset startThumbCenter,
    required Offset endThumbCenter,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final Paint activePaint = Paint()..color = sliderTheme.activeTrackColor!;
    final Paint inactivePaint = Paint()
      ..color = sliderTheme.inactiveTrackColor!;

    context.canvas.drawRect(
      Rect.fromLTRB(
        trackRect.left,
        trackRect.top,
        startThumbCenter.dx,
        trackRect.bottom,
      ),
      inactivePaint,
    );
    context.canvas.drawRect(
      Rect.fromLTRB(
        startThumbCenter.dx,
        trackRect.top,
        endThumbCenter.dx,
        trackRect.bottom,
      ),
      activePaint,
    );
    context.canvas.drawRect(
      Rect.fromLTRB(
        endThumbCenter.dx,
        trackRect.top,
        trackRect.right,
        trackRect.bottom,
      ),
      inactivePaint,
    );
  }
}

class _CustomRangeThumbShape extends RangeSliderThumbShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(4, 120);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool isOnTop = false,
    bool isPressed = false,
    required SliderThemeData sliderTheme,
    TextDirection textDirection = TextDirection.ltr,
    Thumb thumb = Thumb.start,
  }) {
    final curPaint = Paint()..color = sliderTheme.thumbColor!;
    context.canvas.drawRect(
      Rect.fromCenter(center: center, width: 4, height: 120),
      curPaint,
    );
  }
}

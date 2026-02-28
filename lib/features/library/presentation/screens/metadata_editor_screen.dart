import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:SonaPlay/core/constants/app_colors.dart';
import 'package:SonaPlay/core/presentation/widgets/glass_container.dart';
import 'package:SonaPlay/core/presentation/widgets/vibrant_background.dart';
import 'package:SonaPlay/features/player/presentation/providers/palette_provider.dart';
import 'package:SonaPlay/features/library/domain/entities/song.dart';
import 'package:SonaPlay/features/library/presentation/providers/library_provider.dart';
import 'package:SonaPlay/features/library/presentation/widgets/custom_artwork_widget.dart';

class MetadataEditorScreen extends ConsumerStatefulWidget {
  final Song song;

  const MetadataEditorScreen({super.key, required this.song});

  @override
  ConsumerState<MetadataEditorScreen> createState() =>
      _MetadataEditorScreenState();
}

class _MetadataEditorScreenState extends ConsumerState<MetadataEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _artistController;
  late TextEditingController _albumController;
  String? _selectedArtworkPath;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.song.title);
    _artistController = TextEditingController(text: widget.song.artist);
    _albumController = TextEditingController(text: widget.song.album ?? '');
    _selectedArtworkPath = widget.song.artworkPath;

    _titleController.addListener(_onFieldChanged);
    _artistController.addListener(_onFieldChanged);
    _albumController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    final titleChanged = _titleController.text != widget.song.title;
    final artistChanged = _artistController.text != widget.song.artist;
    final albumChanged = _albumController.text != (widget.song.album ?? '');
    final artworkChanged = _selectedArtworkPath != widget.song.artworkPath;

    setState(() {
      _hasChanges =
          titleChanged || artistChanged || albumChanged || artworkChanged;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedArtworkPath = image.path;
        _hasChanges = true;
      });
    }
  }

  Future<void> _saveMetadata() async {
    if (_titleController.text.trim().isEmpty) return;

    final metadataDataSource = ref.read(metadataPersistenceDataSourceProvider);
    await metadataDataSource.saveOverride(
      songId: widget.song.id,
      title: _titleController.text.trim(),
      artist: _artistController.text.trim(),
      album: _albumController.text.trim(),
      artworkPath: _selectedArtworkPath,
    );

    // Refresh songs list
    ref.invalidate(songsProvider);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Etiquetas actualizadas localmente'),
          backgroundColor: AppColors.primaryBlue,
        ),
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          '¿Descartar cambios?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Tienes cambios sin guardar. ¿Estás seguro de que quieres salir?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Descartar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Dynamic Background
            VibrantBackground(accentColor: ref.watch(dominantColorProvider)),
            SafeArea(
              child: Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildArtworkSection(),
                          const SizedBox(height: 32),
                          _buildTextField('NOMBRE', _titleController),
                          const SizedBox(height: 24),
                          _buildTextField('ARTISTA', _artistController),
                          const SizedBox(height: 24),
                          _buildTextField('ÁLBUM', _albumController),
                          const SizedBox(height: 32),
                          _buildFilePathSection(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final isTitleEmpty = _titleController.text.trim().isEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () => Navigator.maybePop(context),
              ),
              const Text(
                'Editar etiquetas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: (isTitleEmpty || !_hasChanges) ? null : _saveMetadata,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.white10,
              disabledForegroundColor: Colors.white24,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: isTitleEmpty ? 0 : 8,
              shadowColor: AppColors.primaryBlue.withValues(alpha: 0.5),
            ),
            child: const Text(
              'Guardar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtworkSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'VERSIÓN',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child:
                    _selectedArtworkPath != null &&
                        !_selectedArtworkPath!.contains('album')
                    ? Image.file(File(_selectedArtworkPath!), fit: BoxFit.cover)
                    : CustomArtworkWidget(
                        songId: int.parse(widget.song.id),
                        size: 140,
                        quality: 100,
                      ),
              ),
            ),
            const SizedBox(width: 24),
            InkWell(
              onTap: _pickImage,
              borderRadius: BorderRadius.circular(12),
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                borderRadius: BorderRadius.circular(12),
                opacity: 0.05,
                child: Row(
                  children: const [
                    Icon(Icons.edit, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Cambiar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white10),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primaryBlue),
            ),
            hintText: 'Introduce el ${label.toLowerCase()}',
            hintStyle: const TextStyle(color: Colors.white12),
          ),
        ),
      ],
    );
  }

  Widget _buildFilePathSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RUTA DEL ARCHIVO',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        GlassContainer(
          padding: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(16),
          opacity: 0.03,
          child: Text(
            widget.song.filePath,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ],
    );
  }
}

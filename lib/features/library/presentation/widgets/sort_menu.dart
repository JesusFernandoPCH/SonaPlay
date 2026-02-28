import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SonaPlay/features/library/presentation/providers/search_filter_provider.dart';

/// Popup menu for sorting songs
class SortMenu extends ConsumerWidget {
  const SortMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSort = ref.watch(sortOptionProvider);

    return PopupMenuButton<SortOption>(
      icon: const Icon(Icons.sort),
      tooltip: 'Sort',
      onSelected: (option) {
        ref.read(sortOptionProvider.notifier).update(option);
      },
      itemBuilder: (context) => [
        _buildMenuItem(SortOption.titleAsc, currentSort),
        _buildMenuItem(SortOption.titleDesc, currentSort),
        const PopupMenuDivider(),
        _buildMenuItem(SortOption.artistAsc, currentSort),
        _buildMenuItem(SortOption.artistDesc, currentSort),
        const PopupMenuDivider(),
        _buildMenuItem(SortOption.albumAsc, currentSort),
        _buildMenuItem(SortOption.albumDesc, currentSort),
        const PopupMenuDivider(),
        _buildMenuItem(SortOption.durationAsc, currentSort),
        _buildMenuItem(SortOption.durationDesc, currentSort),
        const PopupMenuDivider(),
        _buildMenuItem(SortOption.dateAddedAsc, currentSort),
        _buildMenuItem(SortOption.dateAddedDesc, currentSort),
      ],
    );
  }

  PopupMenuItem<SortOption> _buildMenuItem(
    SortOption option,
    SortOption currentSort,
  ) {
    final isSelected = option == currentSort;
    return PopupMenuItem(
      value: option,
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check : null,
            size: 20,
            color: isSelected ? null : Colors.transparent,
          ),
          const SizedBox(width: 8),
          Text(getSortLabel(option)),
        ],
      ),
    );
  }
}

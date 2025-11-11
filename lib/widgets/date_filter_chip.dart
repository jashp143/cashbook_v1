import 'package:flutter/material.dart';

enum DateFilterType {
  today,
  weekly,
  monthly,
  custom,
  all,
}

class DateFilterChip extends StatelessWidget {
  final DateFilterType selectedFilter;
  final Function(DateFilterType) onFilterChanged;

  const DateFilterChip({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        FilterChip(
          label: const Text('Today'),
          selected: selectedFilter == DateFilterType.today,
          onSelected: (_) => onFilterChanged(DateFilterType.today),
        ),
        FilterChip(
          label: const Text('Weekly'),
          selected: selectedFilter == DateFilterType.weekly,
          onSelected: (_) => onFilterChanged(DateFilterType.weekly),
        ),
        FilterChip(
          label: const Text('Monthly'),
          selected: selectedFilter == DateFilterType.monthly,
          onSelected: (_) => onFilterChanged(DateFilterType.monthly),
        ),
        FilterChip(
          label: const Text('Custom'),
          selected: selectedFilter == DateFilterType.custom,
          onSelected: (_) => onFilterChanged(DateFilterType.custom),
        ),
        FilterChip(
          label: const Text('All'),
          selected: selectedFilter == DateFilterType.all,
          onSelected: (_) => onFilterChanged(DateFilterType.all),
        ),
      ],
    );
  }
}


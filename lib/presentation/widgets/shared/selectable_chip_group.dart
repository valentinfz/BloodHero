import 'package:flutter/material.dart';
import 'package:bloodhero/config/theme/layout_constants.dart';

typedef ChipLabelBuilder<T> = String Function(T value);

class SelectableChipGroup<T> extends StatelessWidget {
  final List<T> options;
  final Set<T> selectedValues;
  final ValueChanged<Set<T>> onSelectionChanged;
  final ChipLabelBuilder<T> labelBuilder;
  final bool singleSelection;

  const SelectableChipGroup({
    super.key,
    required this.options,
    required this.selectedValues,
    required this.onSelectionChanged,
    required this.labelBuilder,
    this.singleSelection = false,
  });

  void _handleTap(T value) {
    final newSelection = Set<T>.from(selectedValues);
    final isSelected = newSelection.contains(value);

    if (singleSelection) {
      newSelection.clear();
      if (!isSelected) {
        newSelection.add(value);
      }
    } else {
      if (isSelected) {
        newSelection.remove(value);
      } else {
        newSelection.add(value);
      }
    }

    onSelectionChanged(newSelection);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: kItemSpacing,
      runSpacing: kItemSpacing,
      children: options.map((option) {
        final isSelected = selectedValues.contains(option);
        final label = labelBuilder(option);
        return ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (_) => _handleTap(option),
        );
      }).toList(),
    );
  }
}

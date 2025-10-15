import 'package:flutter/material.dart';
import 'package:bloodhero/config/theme/layout_constants.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final CrossAxisAlignment align;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.align = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final titleWidget = Text(
      title,
      style: Theme.of(context)
          .textTheme
          .headlineSmall
          ?.copyWith(fontWeight: FontWeight.bold),
    );

    final subtitleWidget = subtitle == null
        ? null
        : Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium,
          );

    return Column(
      crossAxisAlignment: align,
      children: [
        if (icon != null)
          Icon(
            icon,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
        if (icon != null) const SizedBox(height: kSmallSpacing),
        titleWidget,
        if (subtitleWidget != null) ...[
          const SizedBox(height: kSmallSpacing),
          subtitleWidget,
        ],
      ],
    );
  }
}

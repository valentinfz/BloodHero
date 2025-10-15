import 'package:flutter/material.dart';
import 'package:bloodhero/config/theme/layout_constants.dart';

class IllustrationPlaceholder extends StatelessWidget {
  final double size;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;

  const IllustrationPlaceholder({
    super.key,
    this.size = 250,
    this.icon = Icons.image_outlined,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
  color: backgroundColor ?? colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(kCardBorderRadius),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: size * 0.4,
        color: iconColor ?? colorScheme.onSurfaceVariant,
      ),
    );
  }
}

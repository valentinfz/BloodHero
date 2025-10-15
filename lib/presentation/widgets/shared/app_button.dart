import 'package:flutter/material.dart';
import 'package:bloodhero/config/theme/layout_constants.dart';

enum AppButtonType { primary, secondary, text }

enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final AppButtonType type;
  final String text;
  final VoidCallback? onPressed;
  final bool expanded;
  final IconData? icon;
  final double? width;
  final AppButtonSize size;

  const AppButton._({
    required this.type,
    required this.text,
    required this.onPressed,
    required this.expanded,
    required this.size,
    this.icon,
    this.width,
    super.key,
  });

  const AppButton.primary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool expanded = true,
    IconData? icon,
    AppButtonSize size = AppButtonSize.medium,
    double? width,
  }) : this._(
          type: AppButtonType.primary,
          text: text,
          onPressed: onPressed,
          expanded: expanded,
          icon: icon,
          size: size,
          width: width,
      key: key,
        );

  const AppButton.secondary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool expanded = true,
    IconData? icon,
    AppButtonSize size = AppButtonSize.medium,
    double? width,
  }) : this._(
          type: AppButtonType.secondary,
          text: text,
          onPressed: onPressed,
          expanded: expanded,
          icon: icon,
          size: size,
          width: width,
      key: key,
        );

  const AppButton.text({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool expanded = false,
    IconData? icon,
    AppButtonSize size = AppButtonSize.small,
    double? width,
  }) : this._(
          type: AppButtonType.text,
          text: text,
          onPressed: onPressed,
          expanded: expanded,
          icon: icon,
          size: size,
          width: width,
          key: key,
        );

  double get _height {
    switch (size) {
      case AppButtonSize.small:
        return 44;
      case AppButtonSize.medium:
        return kButtonHeight;
      case AppButtonSize.large:
        return 64;
    }
  }

  ButtonStyle get _primaryStyle => FilledButton.styleFrom(
        minimumSize: Size.fromHeight(_height),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kCardBorderRadius),
        ),
      );

  ButtonStyle get _secondaryStyle => OutlinedButton.styleFrom(
        minimumSize: Size.fromHeight(_height),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kCardBorderRadius),
        ),
      );

  ButtonStyle get _textStyle => TextButton.styleFrom(
        minimumSize: Size.fromHeight(_height),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      );

  Widget _buildChild() {
    if (icon == null) {
      return Text(text);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonChild = _buildChild();

    Widget button;
    switch (type) {
      case AppButtonType.primary:
        button = FilledButton(
          onPressed: onPressed,
          style: _primaryStyle,
          child: buttonChild,
        );
        break;
      case AppButtonType.secondary:
        button = OutlinedButton(
          onPressed: onPressed,
          style: _secondaryStyle,
          child: buttonChild,
        );
        break;
      case AppButtonType.text:
        button = TextButton(
          onPressed: onPressed,
          style: _textStyle,
          child: buttonChild,
        );
        break;
    }

    return SizedBox(
      width: expanded ? double.infinity : width,
      child: button,
    );
  }
}

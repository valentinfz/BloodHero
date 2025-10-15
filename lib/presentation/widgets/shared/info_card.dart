import 'package:flutter/material.dart';
import 'package:bloodhero/config/theme/layout_constants.dart';

class InfoCard extends StatelessWidget {
  final Widget? leading;
  final String title;
  final List<Widget> body;
  final Widget? trailing;
  final Widget? footer;
  final VoidCallback? onTap;

  const InfoCard({
    super.key,
    this.leading,
    required this.title,
    this.body = const [],
    this.trailing,
    this.footer,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: kSmallSpacing),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (body.isNotEmpty) ...[
                    const SizedBox(height: kSmallSpacing),
                    ...List.generate(
                      body.length,
                      (index) => Padding(
                        padding: EdgeInsets.only(
                          bottom: index == body.length - 1 ? 0 : kSmallSpacing,
                        ),
                        child: body[index],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: kSmallSpacing),
              trailing!,
            ],
          ],
        ),
        if (footer != null) ...[
          const SizedBox(height: kItemSpacing),
          footer!,
        ],
      ],
    );

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kCardBorderRadius),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(kCardBorderRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: content,
        ),
      ),
    );
  }
}

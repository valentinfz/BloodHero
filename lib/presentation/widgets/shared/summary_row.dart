import 'package:flutter/material.dart';
import 'package:bloodhero/config/theme/layout_constants.dart';

class SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final double labelWidth;

  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.labelWidth = 140,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSmallSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

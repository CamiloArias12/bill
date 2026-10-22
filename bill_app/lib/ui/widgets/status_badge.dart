import 'package:bill_app/domain/entities/bill_status.dart';
import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String? value;

  const StatusBadge({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final status = BillStatus.fromValue(value);
    final textColor = status?.textColor ?? const Color(0xFF475569);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status?.backgroundColor ?? const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: status?.dotColor ?? const Color(0xFF94A3B8),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status?.label ?? value ?? 'Sin estado',
            style: TextStyle(
                color: textColor, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

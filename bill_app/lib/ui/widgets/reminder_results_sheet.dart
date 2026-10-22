import 'package:bill_app/config/style_app/style_app.dart';
import 'package:bill_app/domain/entities/reminder_result.dart';
import 'package:bill_app/ui/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

void showReminderResultsSheet(
    BuildContext context, List<ReminderResult> results) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    builder: (_) => _ReminderResults(results: results),
  );
}

class _ReminderResults extends StatelessWidget {
  final List<ReminderResult> results;

  const _ReminderResults({required this.results});

  @override
  Widget build(BuildContext context) {
    final style = GetIt.I.get<StyleApp>();
    final updated = [
      for (final result in results)
        for (final transition in result.updated) (result.clientName, transition)
    ];
    final failed = results.expand((result) => result.failedBillCodes).toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Row(
            children: [
              Icon(Icons.check_circle,
                  color: updated.isEmpty
                      ? style.mutedTextColor
                      : const Color(0xFF10B981)),
              const SizedBox(width: 8),
              Text(
                updated.isEmpty
                    ? 'No había facturas en recordatorio'
                    : 'Se notificaron ${updated.length} facturas',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (failed.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${failed.length} correos no se pudieron enviar (${failed.join(', ')}); su estado no cambió.',
                style: const TextStyle(color: Color(0xFFBE123C)),
              ),
            ),
          const SizedBox(height: 16),
          for (final (clientName, transition) in updated)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: style.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(TextSpan(children: [
                    TextSpan(
                        text: transition.billCode,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    TextSpan(
                        text: ' · $clientName',
                        style: TextStyle(color: style.mutedTextColor)),
                  ])),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      StatusBadge(value: transition.previousStatus),
                      Icon(Icons.arrow_forward,
                          size: 14, color: style.mutedTextColor),
                      StatusBadge(value: transition.newStatus),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

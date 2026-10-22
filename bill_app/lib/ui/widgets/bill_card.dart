import 'package:bill_app/config/style_app/style_app.dart';
import 'package:bill_app/domain/entities/bill.dart';
import 'package:bill_app/domain/entities/client.dart';
import 'package:bill_app/ui/widgets/bill_detail_sheet.dart';
import 'package:bill_app/ui/widgets/status_badge.dart';
import 'package:bill_app/utils/format.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BillCard extends StatelessWidget {
  final Bill bill;
  final Client? client;

  const BillCard({super.key, required this.bill, required this.client});

  @override
  Widget build(BuildContext context) {
    final style = GetIt.I.get<StyleApp>();
    final muted = TextStyle(color: style.mutedTextColor, fontSize: 13);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showBillDetailSheet(context, bill: bill, client: client),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(bill.billCode,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(client?.name ?? '—',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14)),
                        Text('NIT ${client?.nit ?? '—'}', style: muted),
                      ],
                    ),
                  ),
                  StatusBadge(value: bill.status),
                ],
              ),
              Divider(height: 24, color: style.borderColor),
              Row(
                children: [
                  Icon(Icons.place_outlined,
                      size: 16, color: style.mutedTextColor),
                  const SizedBox(width: 4),
                  Text(bill.city ?? '—', style: muted),
                  const SizedBox(width: 12),
                  Icon(Icons.calendar_today_outlined,
                      size: 14, color: style.mutedTextColor),
                  const SizedBox(width: 4),
                  Text(formatDate(bill.creationDate), style: muted),
                  const Spacer(),
                  Text(formatCurrency(bill.billTotal),
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

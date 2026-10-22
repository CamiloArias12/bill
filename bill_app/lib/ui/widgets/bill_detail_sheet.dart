import 'package:bill_app/config/style_app/style_app.dart';
import 'package:bill_app/domain/entities/bill.dart';
import 'package:bill_app/domain/entities/client.dart';
import 'package:bill_app/ui/widgets/status_badge.dart';
import 'package:bill_app/utils/format.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

void showBillDetailSheet(BuildContext context,
    {required Bill bill, required Client? client}) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (_) => _BillDetail(bill: bill, client: client),
  );
}

class _BillDetail extends StatelessWidget {
  final Bill bill;
  final Client? client;

  const _BillDetail({required this.bill, required this.client});

  @override
  Widget build(BuildContext context) {
    final style = GetIt.I.get<StyleApp>();

    Widget row(String label, String value, {bool bold = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Text(label, style: TextStyle(color: style.mutedTextColor)),
              const Spacer(),
              Text(value,
                  style: TextStyle(
                      fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
                      fontSize: bold ? 17 : 14)),
            ],
          ),
        );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(bill.billCode,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600)),
                const Spacer(),
                StatusBadge(value: bill.status),
              ],
            ),
            const SizedBox(height: 4),
            Text('${client?.name ?? '—'} · NIT ${client?.nit ?? '—'}',
                style: TextStyle(color: style.mutedTextColor)),
            if (client != null)
              Text(client!.email,
                  style: TextStyle(color: style.mutedTextColor)),
            Divider(height: 28, color: style.borderColor),
            row('Ciudad', bill.city ?? '—'),
            row('Fecha de creación', formatDate(bill.creationDate)),
            row('Subtotal', formatCurrency(bill.subtotal)),
            row('IVA', formatCurrency(bill.vat)),
            row('Retención', formatCurrency(bill.withholding)),
            row(
                'Pago',
                bill.isPaid == true
                    ? 'Pagada · ${formatDate(bill.paymentDate)}'
                    : 'Pendiente'),
            Divider(height: 20, color: style.borderColor),
            row('Total', formatCurrency(bill.billTotal), bold: true),
          ],
        ),
      ),
    );
  }
}

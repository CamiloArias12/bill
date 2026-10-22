import 'package:bill_app/config/style_app/style_app.dart';
import 'package:bill_app/domain/entities/bill.dart';
import 'package:bill_app/domain/entities/bill_status.dart';
import 'package:bill_app/utils/format.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BillSummary extends StatelessWidget {
  final List<Bill> bills;
  final BillStatus? selectedStatus;
  final ValueChanged<BillStatus?> onSelectStatus;

  const BillSummary({
    super.key,
    required this.bills,
    required this.selectedStatus,
    required this.onSelectStatus,
  });

  double _sum(Iterable<Bill> bills) =>
      bills.fold(0, (total, bill) => total + (bill.billTotal ?? 0));

  @override
  Widget build(BuildContext context) {
    final cards = [
      _SummaryCard(
        label: 'Todas',
        count: bills.length,
        total: _sum(bills),
        selected: selectedStatus == null,
        onTap: () => onSelectStatus(null),
      ),
      for (final status in BillStatus.values)
        () {
          final statusBills = bills.where((bill) => bill.billStatus == status);
          return _SummaryCard(
            label: status.label,
            dotColor: status.dotColor,
            count: statusBills.length,
            total: _sum(statusBills),
            selected: selectedStatus == status,
            onTap: () =>
                onSelectStatus(selectedStatus == status ? null : status),
          );
        }(),
    ];

    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) => cards[index],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final Color? dotColor;
  final int count;
  final double total;
  final bool selected;
  final VoidCallback onTap;

  const _SummaryCard({
    required this.label,
    this.dotColor,
    required this.count,
    required this.total,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = GetIt.I.get<StyleApp>();

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? style.primaryColor : style.borderColor,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 176,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (dotColor != null) ...[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: dotColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                    child: Text(label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: style.mutedTextColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
              Text('$count',
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w600, height: 1)),
              Text(formatCurrency(total),
                  style: TextStyle(color: style.mutedTextColor, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

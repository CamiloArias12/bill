import 'package:bill_app/domain/entities/bill.dart';
import 'package:bill_app/domain/entities/client.dart';
import 'package:bill_app/utils/client_find.dart';
import 'package:flutter/material.dart';

class BillTable extends StatelessWidget {
  final List<Bill> bills;
  final List<Client> clients;

  const BillTable({super.key, required this.bills, required this.clients});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Codigo factura')),
          DataColumn(label: Text('Cliente')),
          DataColumn(label: Text('Nit')),
          DataColumn(label: Text('Ciudad')),
          DataColumn(label: Text('Total Factura')),
          DataColumn(label: Text('Subtotal')),
          DataColumn(label: Text('Iva')),
          DataColumn(label: Text('Retencion')),
          DataColumn(label: Text('Fecha de creacion')),
          DataColumn(label: Text('Estado')),
          DataColumn(label: Text('Pagada')),
          DataColumn(label: Text('Fecha de pago')),
        ],
        rows: bills.map((bill) {
          return DataRow(cells: [
            DataCell(Text(bill.billCode)),
            DataCell(Text(getClientNameById(bill.clientId ?? "", clients))),
            DataCell(Text(getClientNitById(bill.clientId ?? "", clients))),
            DataCell(Text(bill.city ?? 'N/A')),
            DataCell(Text(bill.billTotal?.toStringAsFixed(2) ?? 'N/A')),
            DataCell(Text(bill.subtotal?.toStringAsFixed(2) ?? 'N/A')),
            DataCell(Text(bill.vat?.toStringAsFixed(2) ?? 'N/A')),
            DataCell(Text(bill.withholding?.toStringAsFixed(2) ?? 'N/A')),
            DataCell(
                Text(bill.creationDate.toIso8601String().split('T').first)),
            DataCell(Text(bill.status ?? 'N/A')),
            DataCell(Text(bill.isPaid == true ? 'Si' : 'No')),
            DataCell(Text(
                bill.paymentDate?.toIso8601String().split('T').first ?? 'N/A')),
          ]);
        }).toList(),
      ),
    );
  }
}

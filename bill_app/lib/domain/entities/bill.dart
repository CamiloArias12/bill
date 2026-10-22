import 'dart:convert';

import 'package:bill_app/domain/entities/bill_status.dart';

class Bill {
  String id;
  String billCode;
  double? billTotal;
  double? subtotal;
  double? vat;
  double? withholding;
  DateTime creationDate;
  String? status;
  String? city;
  bool? isPaid;
  DateTime? paymentDate;
  String? clientId;

  Bill({
    required this.id,
    required this.billCode,
    this.billTotal,
    this.subtotal,
    this.vat,
    this.withholding,
    required this.creationDate,
    this.status,
    this.city,
    this.isPaid,
    this.paymentDate,
    this.clientId,
  });

  BillStatus? get billStatus => BillStatus.fromValue(status);

  factory Bill.fromJson(String json) => Bill.fromMap(jsonDecode(json));

  String toJson() => jsonEncode(toMap());

  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      id: map['id'],
      billCode: map['billCode'],
      billTotal: (map['billTotal'] as num?)?.toDouble(),
      subtotal: (map['subtotal'] as num?)?.toDouble(),
      vat: (map['vat'] as num?)?.toDouble(),
      withholding: (map['withholding'] as num?)?.toDouble(),
      creationDate: DateTime.parse(map['creationDate']),
      status: map['status'],
      city: map['city'],
      isPaid: map['isPaid'],
      paymentDate: map['paymentDate'] != null
          ? DateTime.parse(map['paymentDate'])
          : null,
      clientId: map['clientId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'billCode': billCode,
      'billTotal': billTotal,
      'subtotal': subtotal,
      'vat': vat,
      'withholding': withholding,
      'creationDate': creationDate.toIso8601String(),
      'status': status,
      'city': city,
      'isPaid': isPaid,
      'paymentDate': paymentDate?.toIso8601String(),
      'clientId': clientId,
    };
  }
}

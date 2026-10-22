import 'dart:convert';

class Bill {
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

  factory Bill.fromJson(String json) => Bill.fromMap(jsonDecode(json));

  String toJson() => jsonEncode(toMap());

  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      billCode: map['billCode'],
      billTotal: double.parse(map['billTotal'].toString()),
      subtotal: double.parse(map['subtotal'].toString()),
      vat: double.parse(map['vat'].toString()),
      withholding: double.parse(map['withholding'].toString()),
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

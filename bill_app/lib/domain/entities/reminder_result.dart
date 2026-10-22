class BillTransition {
  final String billCode;
  final String previousStatus;
  final String newStatus;

  BillTransition({
    required this.billCode,
    required this.previousStatus,
    required this.newStatus,
  });

  factory BillTransition.fromMap(Map<String, dynamic> map) {
    return BillTransition(
      billCode: map['billCode'],
      previousStatus: map['previousStatus'],
      newStatus: map['newStatus'],
    );
  }
}

class ReminderResult {
  final String clientId;
  final String clientName;
  final List<BillTransition> updated;
  final List<String> failedBillCodes;

  ReminderResult({
    required this.clientId,
    required this.clientName,
    required this.updated,
    required this.failedBillCodes,
  });

  factory ReminderResult.fromMap(Map<String, dynamic> map) {
    return ReminderResult(
      clientId: map['clientId'],
      clientName: map['clientName'],
      updated: (map['updated'] as List)
          .map((item) => BillTransition.fromMap(item))
          .toList(),
      failedBillCodes: List<String>.from(map['failedBillCodes']),
    );
  }
}

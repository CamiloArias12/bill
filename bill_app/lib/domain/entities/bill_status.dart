import 'package:flutter/material.dart';

enum BillStatus {
  firstReminder('primerrecordatorio', 'Primer recordatorio', Color(0xFFF59E0B),
      Color(0xFFFFFBEB), Color(0xFFB45309)),
  secondReminder('segundorecordatorio', 'Segundo recordatorio',
      Color(0xFFF97316), Color(0xFFFFF7ED), Color(0xFFC2410C)),
  disabled('desactivado', 'Desactivado', Color(0xFFF43F5E), Color(0xFFFFF1F2),
      Color(0xFFBE123C));

  const BillStatus(this.value, this.label, this.dotColor, this.backgroundColor,
      this.textColor);

  final String value;
  final String label;
  final Color dotColor;
  final Color backgroundColor;
  final Color textColor;

  // La API puede devolver "primerRecordatorio" o "primerrecordatorio".
  static BillStatus? fromValue(String? value) {
    final normalized = value?.trim().toLowerCase();
    for (final status in BillStatus.values) {
      if (status.value == normalized) return status;
    }
    return null;
  }
}

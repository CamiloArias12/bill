import 'package:bill_app/domain/entities/bill.dart';
import 'package:bill_app/domain/entities/reminder_result.dart';

class BillState {}

class BillStartState extends BillState {
  BillStartState();
}

class BillErrorState extends BillState {
  final String message;
  BillErrorState({required this.message});
}

class BillLoadingState extends BillState {}

class BillLoadedState extends BillState {
  final List<Bill> bills;
  final bool processing;
  // Resultado del último envío de recordatorios, para mostrarlo una sola vez.
  final List<ReminderResult>? results;
  final String? processError;

  BillLoadedState({
    required this.bills,
    this.processing = false,
    this.results,
    this.processError,
  });
}

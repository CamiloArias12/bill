import 'package:bill_app/domain/entities/bill.dart';

class BillState {}

class BillStartState extends BillState {
  BillStartState();
}

class BillErrorState extends BillState {}

class BillLoadingState extends BillState {}

class BillLoadedState extends BillState {
  final List<Bill> bills;
  BillLoadedState({required this.bills});
}

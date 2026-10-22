import 'package:bill_app/bloc/Bill/event.dart';
import 'package:bill_app/bloc/Bill/state.dart';
import 'package:bill_app/domain/entities/bill.dart';
import 'package:bill_app/services/bill_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class BillBloc extends Bloc<BillEvent, BillState> {
  late final AbstractBillService billService;

  BillBloc() : super(BillStartState()) {
    billService = GetIt.I.get<AbstractBillService>();

    on<BillFetchEvent>(_fetchAllBill);
    on<BillProcessRemindersEvent>(_processReminders);
  }

  List<Bill> get _currentBills {
    final current = state;
    return current is BillLoadedState ? current.bills : [];
  }

  Future<void> _fetchAllBill(BillFetchEvent event, Emitter emit) async {
    if (state is! BillLoadedState) emit(BillLoadingState());
    try {
      List<Bill> bills = await billService.fetchAll();
      emit(BillLoadedState(bills: bills));
    } catch (e) {
      debugPrint('$e');
      emit(BillErrorState(message: 'No se pudieron cargar las facturas'));
    }
  }

  Future<void> _processReminders(
      BillProcessRemindersEvent event, Emitter emit) async {
    emit(BillLoadedState(bills: _currentBills, processing: true));
    try {
      final results =
          await billService.processReminders(clientId: event.clientId);
      final bills = await billService.fetchAll();
      emit(BillLoadedState(bills: bills, results: results));
    } catch (e) {
      debugPrint('$e');
      emit(BillLoadedState(
          bills: _currentBills,
          processError: 'No se pudo ejecutar el proceso de recordatorios'));
    }
  }
}

import 'package:bill_app/bloc/Bill/event.dart';
import 'package:bill_app/bloc/Bill/state.dart';
import 'package:bill_app/domain/entities/bill.dart';
import 'package:bill_app/services/bill_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class BillBloc extends Bloc<BillEvent, BillState> {
  late final AbstractBillService billService;

  BillBloc() : super(BillStartState()) {
    billService = GetIt.I.get<AbstractBillService>();

    on<BillFetchEvent>(_fetchAllBill);
  }

  Future<void> _fetchAllBill(BillEvent event, Emitter emit) async {
    emit(BillLoadingState());
    try {
      List<Bill> bills = await billService.fetchAll();
      emit(BillLoadedState(bills: bills));
    } catch (e) {
      print(e);
      emit(BillErrorState());
    }
  }
}

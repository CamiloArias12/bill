import 'package:bill_app/bloc/Bill/bloc.dart';
import 'package:bill_app/bloc/Bill/event.dart';
import 'package:bill_app/bloc/Bill/state.dart';
import 'package:bill_app/bloc/Client/bloc.dart';
import 'package:bill_app/bloc/Client/event.dart';
import 'package:bill_app/bloc/Client/state.dart';
import 'package:bill_app/config/style_app/style_app.dart';
import 'package:bill_app/ui/widgets/table_bill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class BillPage extends StatefulWidget {
  late final BillBloc billBloc;
  late final ClientBloc clientBloc;
  late final StyleApp styleApp;

  BillPage({super.key}) {
    clientBloc = GetIt.I.get<ClientBloc>();
    billBloc = GetIt.I.get<BillBloc>();
    styleApp = GetIt.I.get<StyleApp>();
  }

  @override
  State<StatefulWidget> createState() => _BillPage();
}

class _BillPage extends State<BillPage> {
  @override
  void initState() {
    widget.billBloc.add(BillFetchEvent());
    widget.clientBloc.add(ClientFetchEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: widget.styleApp.primaryColor,
            foregroundColor: Colors.white,
            title: const Text('Facturas')),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: BlocBuilder<BillBloc, BillState>(builder: (context, state) {
            if (state is! BillLoadedState) {
              return Center(
                  child: CircularProgressIndicator(
                color: widget.styleApp.primaryColor,
              ));
            }
            return BlocBuilder<ClientBloc, ClientState>(
                builder: (context, stateClient) {
              if (stateClient is! ClientLoadedState) {
                return Center(
                    child: CircularProgressIndicator(
                  color: widget.styleApp.primaryColor,
                ));
              }
              return BillTable(
                bills: state.bills,
                clients: stateClient.clients,
              );
            });
          }),
        ));
  }
}

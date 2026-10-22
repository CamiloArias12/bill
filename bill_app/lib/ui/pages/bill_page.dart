import 'package:bill_app/bloc/Bill/bloc.dart';
import 'package:bill_app/bloc/Bill/event.dart';
import 'package:bill_app/bloc/Bill/state.dart';
import 'package:bill_app/bloc/Client/bloc.dart';
import 'package:bill_app/bloc/Client/event.dart';
import 'package:bill_app/bloc/Client/state.dart';
import 'package:bill_app/config/style_app/style_app.dart';
import 'package:bill_app/domain/entities/bill.dart';
import 'package:bill_app/domain/entities/bill_status.dart';
import 'package:bill_app/domain/entities/client.dart';
import 'package:bill_app/ui/widgets/bill_card.dart';
import 'package:bill_app/ui/widgets/bill_summary.dart';
import 'package:bill_app/ui/widgets/reminder_results_sheet.dart';
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
  String? _clientId;
  BillStatus? _status;
  String _search = '';

  @override
  void initState() {
    widget.billBloc.add(BillFetchEvent());
    widget.clientBloc.add(ClientFetchEvent());
    super.initState();
  }

  Future<void> _refresh() async {
    widget.billBloc.add(BillFetchEvent());
    widget.clientBloc.add(ClientFetchEvent());
    await widget.billBloc.stream
        .firstWhere((state) => state is! BillLoadingState);
  }

  void _onBillStateChanged(BuildContext context, BillState state) {
    if (state is! BillLoadedState) return;
    if (state.results != null) {
      showReminderResultsSheet(context, state.results!);
    } else if (state.processError != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(state.processError!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.styleApp;

    return BlocConsumer<BillBloc, BillState>(
      listener: _onBillStateChanged,
      builder: (context, billState) {
        return BlocBuilder<ClientBloc, ClientState>(
          builder: (context, clientState) {
            final clients = clientState is ClientLoadedState
                ? clientState.clients
                : <Client>[];
            final processing =
                billState is BillLoadedState && billState.processing;

            return Scaffold(
              appBar: AppBar(
                titleSpacing: 16,
                toolbarHeight: 68,
                title: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: style.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.receipt_long,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Facturas',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                        Text('Seguimiento de recordatorios de pago',
                            style: TextStyle(
                                fontSize: 13, color: style.mutedTextColor)),
                      ],
                    ),
                  ],
                ),
              ),
              floatingActionButton: billState is BillLoadedState
                  ? FloatingActionButton.extended(
                      backgroundColor: style.primaryColor,
                      foregroundColor: Colors.white,
                      onPressed: processing
                          ? null
                          : () => widget.billBloc.add(
                              BillProcessRemindersEvent(clientId: _clientId)),
                      icon: processing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.send_outlined),
                      label: Text(processing
                          ? 'Enviando...'
                          : _clientId == null
                              ? 'Enviar recordatorios'
                              : 'Enviar a este cliente'),
                    )
                  : null,
              body: switch (billState) {
                BillErrorState(:final message) => _ErrorView(
                    message: message,
                    onRetry: () => widget.billBloc.add(BillFetchEvent())),
                BillLoadedState(:final bills) => RefreshIndicator(
                    color: style.primaryColor,
                    onRefresh: _refresh,
                    child: _buildContent(bills, clients),
                  ),
                _ => Center(
                    child:
                        CircularProgressIndicator(color: style.primaryColor)),
              },
            );
          },
        );
      },
    );
  }

  Widget _buildContent(List<Bill> bills, List<Client> clients) {
    final style = widget.styleApp;
    final clientsById = {for (final client in clients) client.id: client};
    final clientBills = _clientId == null
        ? bills
        : bills.where((bill) => bill.clientId == _clientId).toList();
    final term = _search.trim().toLowerCase();
    final visibleBills = clientBills
        .where((bill) =>
            (_status == null || bill.billStatus == _status) &&
            (term.isEmpty ||
                bill.billCode.toLowerCase().contains(term) ||
                (bill.city?.toLowerCase().contains(term) ?? false)))
        .toList();

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final (id, name) in [
                    (null, 'Todos los clientes'),
                    for (final client in clients) (client.id, client.name)
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(name),
                        selected: _clientId == id,
                        showCheckmark: false,
                        labelStyle: TextStyle(
                            color: _clientId == id
                                ? style.primaryColor
                                : const Color(0xFF334155),
                            fontWeight: FontWeight.w500),
                        onSelected: (_) => setState(() => _clientId = id),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: BillSummary(
              bills: clientBills,
              selectedStatus: _status,
              onSelectStatus: (status) => setState(() => _status = status),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(TextSpan(children: [
                  const TextSpan(
                      text: 'Detalle ',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  TextSpan(
                      text: '(${visibleBills.length})',
                      style:
                          TextStyle(fontSize: 16, color: style.mutedTextColor)),
                ])),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (value) => setState(() => _search = value),
                  decoration: InputDecoration(
                    hintText: 'Buscar por código o ciudad',
                    prefixIcon: Icon(Icons.search, color: style.mutedTextColor),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (visibleBills.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Text('No hay facturas que coincidan con los filtros.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: style.mutedTextColor)),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
          sliver: SliverList.separated(
            itemCount: visibleBills.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final bill = visibleBills[index];
              return BillCard(bill: bill, client: clientsById[bill.clientId]);
            },
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 48, color: Color(0xFF94A3B8)),
          const SizedBox(height: 12),
          Text(message),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}

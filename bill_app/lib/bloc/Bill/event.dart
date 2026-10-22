class BillEvent {}

class BillFetchEvent extends BillEvent {}

class BillProcessRemindersEvent extends BillEvent {
  final String? clientId;
  BillProcessRemindersEvent({this.clientId});
}

import 'package:intl/intl.dart';

final _brl = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ', decimalDigits: 2);

String fmtBRL(num value) => _brl.format(value);

String fmtNum(num value, [int decimals = 0]) {
  final f = NumberFormat.decimalPattern('pt_BR');
  f.minimumFractionDigits = decimals;
  f.maximumFractionDigits = decimals;
  return f.format(value);
}

String fmtDate(DateTime d, {bool long = false}) {
  final f = long ? DateFormat("d 'de' MMMM 'de' y", 'pt_BR') : DateFormat('dd/MM', 'pt_BR');
  return f.format(d);
}

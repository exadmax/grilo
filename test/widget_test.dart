import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:grilo/main.dart';

void main() {
  testWidgets('GriloApp renders the calculator screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: GriloApp()));
    await tester.pumpAndSettle();

    expect(find.text('Calculadora'), findsWidgets);
  });
}

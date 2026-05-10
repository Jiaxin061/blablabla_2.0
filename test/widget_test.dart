import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vbla_farm/main.dart';

void main() {
  testWidgets('VBlaFarmApp builds', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: VBlaFarmApp()),
    );
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

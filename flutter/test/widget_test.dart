import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:affiliatepro_mobile/view/base/custom_text_field.dart';

void main() {
  testWidgets('CustomTextField neón se construye y enfoca', (WidgetTester tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomTextField(
            textEditingController: controller,
            hintText: 'Username',
            type: 2,
          ),
        ),
      ),
    );

    expect(find.byType(TextFormField), findsOneWidget);
    await tester.tap(find.byType(TextFormField));
    await tester.pump(const Duration(milliseconds: 250));
    expect(tester.takeException(), isNull);
  });
}

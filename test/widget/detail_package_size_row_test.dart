import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptncenter/models/unit_size_model.dart';
import 'package:ptncenter/widget/detail_package_size_row.dart';

Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('PackageSizeRow', () {
    testWidgets('shows price/label and a quantity spinner when in stock',
        (tester) async {
      final unit = UnitSizeModel(lable: 'กล่อง', price: '120', unit: 'บาท');

      await tester.pumpWidget(wrap(PackageSizeRow(
        unitSizeModel: unit,
        currentQtyInCart: 0,
        limit: 10,
        onQuantityChanged: (_) {},
      )));

      expect(find.textContaining('120 บาท'), findsOneWidget);
      expect(find.text('กล่อง'), findsOneWidget);
      expect(find.textContaining('งดจำหน่าย'), findsNothing);
      expect(find.byType(SpinBox), findsOneWidget);
    });

    testWidgets('shows งดจำหน่าย and a read-only field when the size is out of stock',
        (tester) async {
      final unit = UnitSizeModel(lable: 'กล่อง', price: '0', unit: 'บาท');

      await tester.pumpWidget(wrap(PackageSizeRow(
        unitSizeModel: unit,
        currentQtyInCart: 3,
        limit: 10,
        onQuantityChanged: (_) {},
      )));

      expect(find.textContaining('งดจำหน่าย'), findsOneWidget);
      expect(find.byType(SpinBox), findsNothing);
      final field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.initialValue, '3');
    });

    testWidgets('reports the new quantity when the spinner is incremented',
        (tester) async {
      final unit = UnitSizeModel(lable: 'กล่อง', price: '120', unit: 'บาท');
      int? reported;

      await tester.pumpWidget(wrap(PackageSizeRow(
        unitSizeModel: unit,
        currentQtyInCart: 0,
        limit: 10,
        onQuantityChanged: (value) => reported = value,
      )));

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(reported, 1);
    });
  });
}

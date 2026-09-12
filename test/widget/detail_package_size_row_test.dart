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

      expect(find.textContaining('120 /'), findsOneWidget);
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

    testWidgets(
        'does not overflow on a narrow screen even with a long price label',
        (tester) async {
      final view = tester.view;
      view.physicalSize = const Size(320, 640);
      view.devicePixelRatio = 1.0;
      addTearDown(view.resetPhysicalSize);
      addTearDown(view.resetDevicePixelRatio);

      final unit = UnitSizeModel(
        lable: 'แผงยาวมากๆขนาดใหญ่พิเศษ (คละสี)',
        price: '1234.50',
        unit: 'บาท',
      );

      await tester.pumpWidget(wrap(PackageSizeRow(
        unitSizeModel: unit,
        currentQtyInCart: 0,
        limit: 10,
        onQuantityChanged: (_) {},
      )));

      expect(tester.takeException(), isNull);
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

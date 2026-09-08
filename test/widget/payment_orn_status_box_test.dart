import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptncenter/widget/payment_orn_status_box.dart';

Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('OrnStatusBox', () {
    testWidgets('shows the mapped status text for a known status code',
        (tester) async {
      await tester.pumpWidget(wrap(const OrnStatusBox(status: '5')));
      expect(find.textContaining('ชำระแล้ว'), findsOneWidget);
    });

    testWidgets('falls back to an empty label for an unknown status code',
        (tester) async {
      await tester.pumpWidget(wrap(const OrnStatusBox(status: 'unknown')));
      expect(tester.takeException(), isNull);
      expect(find.textContaining('สถานะ ORN'), findsOneWidget);
    });

    testWidgets('falls back gracefully when status is null', (tester) async {
      await tester.pumpWidget(wrap(const OrnStatusBox(status: null)));
      expect(tester.takeException(), isNull);
    });
  });

  group('LinkedToBillBox', () {
    testWidgets('mentions both the orn and the bill it was merged into',
        (tester) async {
      await tester.pumpWidget(wrap(
          const LinkedToBillBox(ornNo: 'ORN-100', billNo: 'BILL-999')));

      expect(find.textContaining('ORN-100'), findsOneWidget);
      expect(find.textContaining('BILL-999'), findsOneWidget);
    });
  });

  group('PaymentCompleteBox', () {
    testWidgets('shows the given title and message', (tester) async {
      await tester.pumpWidget(wrap(const PaymentCompleteBox(
        title: 'ชำระเงินสำเร็จ',
        message: 'ระบบได้รับการชำระเงินของคุณเรียบร้อยแล้ว',
      )));

      expect(find.text('ชำระเงินสำเร็จ'), findsOneWidget);
      expect(find.text('ระบบได้รับการชำระเงินของคุณเรียบร้อยแล้ว'),
          findsOneWidget);
    });
  });
}

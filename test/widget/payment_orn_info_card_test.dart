import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptncenter/models/orn_model.dart';
import 'package:ptncenter/widget/payment_orn_info_card.dart';

Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('PaymentOrnInfoCard', () {
    testWidgets('shows the core fields with comma-formatted amounts',
        (tester) async {
      final orn = OrnModel(
        ornNo: 'ORN-001',
        amount: '1234.5',
        total: '1300',
        paytype: 'โอนเงิน',
        paydate: '01/01/2569',
        billingStatus: 'รอเก็บบิล',
        billNo: '-',
      );

      await tester.pumpWidget(wrap(PaymentOrnInfoCard(ornModel: orn)));

      expect(find.text('ORN-001'), findsOneWidget);
      expect(find.text('1,234.50 บาท'), findsOneWidget);
      expect(find.text('1,300.00 บาท'), findsOneWidget);
      expect(find.text('โอนเงิน'), findsOneWidget);
      // ไม่มีค่าจัดส่ง/ยาคืน (null) จึงไม่ควรมีป้ายกำกับนั้นขึ้นมา
      expect(find.text('ค่าจัดส่ง :'), findsNothing);
      expect(find.text('ยาคืน :'), findsNothing);
    });

    testWidgets('shows shipping and cn rows only when they are set and non-zero',
        (tester) async {
      final orn = OrnModel(
        ornNo: 'ORN-002',
        amount: '100',
        total: '150',
        shipping: '50',
        cn: '0',
      );

      await tester.pumpWidget(wrap(PaymentOrnInfoCard(ornModel: orn)));

      expect(find.text('ค่าจัดส่ง :'), findsOneWidget);
      expect(find.text('50.00 บาท'), findsOneWidget);
      // cn = '0' ถือว่าไม่มียาคืน ไม่ควรแสดงแถวนี้
      expect(find.text('ยาคืน :'), findsNothing);
    });

    testWidgets('renders empty field values gracefully when ornModel is null',
        (tester) async {
      await tester.pumpWidget(wrap(const PaymentOrnInfoCard(ornModel: null)));

      expect(tester.takeException(), isNull);
      expect(find.text('เลขที่ใบส่งของ :'), findsOneWidget);
    });
  });
}

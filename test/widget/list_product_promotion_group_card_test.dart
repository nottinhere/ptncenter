import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptncenter/models/gift_model.dart';
import 'package:ptncenter/models/promotion_group_model.dart';
import 'package:ptncenter/widget/list_product_promotion_group_card.dart';

Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('GroupPromotionCard', () {
    testWidgets('renders nothing when there is no group', (tester) async {
      await tester.pumpWidget(wrap(const GroupPromotionCard(
        currentPromotionGroup: null,
        cartValueByProduct: {},
        giftMap: {},
      )));

      expect(find.text('ขั้น 1'), findsNothing);
    });

    testWidgets('sums cart value only for products belonging to the group',
        (tester) async {
      final group = PromotionGroupModel(
        med: '1,2,3',
        target: '100',
        gift: 'G1',
        getqty: '1',
      );
      final giftMap = {'G1': GiftModel(name: 'ของแถม')};
      // product 4 is not in the group -> its value must not count toward subtotal
      final cartValueByProduct = {1: 40.0, 2: 40.0, 4: 1000.0};

      await tester.pumpWidget(wrap(GroupPromotionCard(
        currentPromotionGroup: group,
        cartValueByProduct: cartValueByProduct,
        giftMap: giftMap,
      )));

      // subtotal = 40 + 40 = 80, ยังไม่ถึง target 100
      expect(find.textContaining('ยอดในกลุ่มปัจจุบัน 80 บาท'), findsOneWidget);
      expect(find.textContaining('สำเร็จ'), findsNothing);
    });

    testWidgets('marks the highest reached tier as สำเร็จ and greys out lower ones',
        (tester) async {
      final group = PromotionGroupModel(
        med: '1',
        target: '100',
        gift: 'G1',
        getqty: '1',
        target2: '200',
        gift2: 'G2',
        getqty2: '2',
      );
      final giftMap = {
        'G1': GiftModel(name: 'ของแถม1'),
        'G2': GiftModel(name: 'ของแถม2'),
      };

      await tester.pumpWidget(wrap(GroupPromotionCard(
        currentPromotionGroup: group,
        cartValueByProduct: const {1: 200.0},
        giftMap: giftMap,
      )));

      // ขั้น 1 (ผ่านแล้ว, สีเทา) และขั้น 2 (ปัจจุบัน, สำเร็จ) รวมเป็น "สำเร็จ" 1 ครั้ง
      expect(find.textContaining('สำเร็จ'), findsOneWidget);
    });

    testWidgets('does not overflow when showing the next-tier progress row',
        (tester) async {
      final group = PromotionGroupModel(
        med: '1',
        target: '500',
        gift: 'G1',
        getqty: '1',
      );
      final giftMap = {'G1': GiftModel(name: 'ของแถม')};

      await tester.pumpWidget(wrap(GroupPromotionCard(
        currentPromotionGroup: group,
        cartValueByProduct: const {1: 250.0},
        giftMap: giftMap,
      )));

      expect(tester.takeException(), isNull);
      expect(find.textContaining('ขาดอีก'), findsOneWidget);
    });
  });
}
